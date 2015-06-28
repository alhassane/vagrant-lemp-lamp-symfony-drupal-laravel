<?php
/**
 * This file is part of the project.
 *
 * @category   EventListener
 * @package    Handler
 * @subpackage Exception
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Dirisi\WebsiteBundle\EventListener;

use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Bundle\FrameworkBundle\Templating\EngineInterface;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpKernel\HttpKernelInterface;

/**
 * Custom Exception handler.
 *
 * @category   EventListener
 * @package    Handler
 * @subpackage Exception
 */
class HandlerException
{
    /**
     * @var EngineInterface $templating The templating service
     */
    protected $templating;
    
    /**
     * @var string $locale The locale value
     */
    protected $locale;
    
    /**
     * @var ContainerInterface $container The service container
     */
    protected $container;
    
    /**
     * @var \AppKernel $kernel Kernel service
     */
    protected $kernel;    
    
    /**
     * Constructor.
     * 
     * @param EngineInterface    $templating The templating service
     * @param \AppKernel         $kernel     The kernel service
     * @param ContainerInterface $container  The containerservice
     */
    public function __construct(
        EngineInterface $templating,
        \AppKernel $kernel,
        ContainerInterface $container
    ) {
        $this->container  = $container;
        $this->templating = $templating;
        $this->locale     = $this->container->get('request')->getLocale();
        $this->kernel     = $kernel;
    }

    /**
     * Event handler that renders not found page
     * in case of a NotFoundHttpException
     *
     * @param GetResponseForExceptionEvent $event
     *
     * @access public
     * @return void
     */    
    public function onKernelException(GetResponseForExceptionEvent $event)
    {
        $this->request = $event->getRequest($event);
        // provide the better way to display a enhanced error page only in prod environment, if you want
        if ('prod' == $this->kernel->getEnvironment()) {
            // exception object
            $exception = $event->getException();
            // new Response object
            $response = new Response();

            //$kernel = $event->getKernel();
            //$requestDuplicate = $event->getRequest()->duplicate(null, null, ['_controller' => 'DirisiWebsiteBundle:Default:exception']);
            //$response = $kernel->handle($requestDuplicate, HttpKernelInterface::SUB_REQUEST);

            // HttpExceptionInterface is a special type of exception
            // that holds status code and header details
            if (method_exists($exception, "getStatusCode")) {
                $response->setStatusCode($exception->getStatusCode());
            } else {
                $response->setStatusCode(404);
            }
            if (method_exists($response, "getHeaders")) {
                $response->headers->replace($exception->getHeaders());
            }
            // set the new $response object to the $event
            $event->setResponse($response);
            
        }
    }
}