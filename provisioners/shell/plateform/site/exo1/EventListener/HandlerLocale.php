<?php
/**
 * This file is part of the project.
 *
 * @category   EventListener
 * @package    Handler
 * @subpackage Request
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace MyApp\SiteBundle\EventListener;

use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpKernel\Event\GetResponseEvent;
use Symfony\Component\HttpKernel\HttpKernel;

/**
 * Custom locale handler.
 *
 * @category   EventListener
 * @package    Handler
 * @subpackage Request
 */
class HandlerLocale
{
    /**
     * @var string
     */    
   protected $defaultLocale;
   
   /**
    * @var \Symfony\Component\DependencyInjection\ContainerInterface
    */
   protected $container;   

   /**
    * Constructor.
    *
    * @param string             $defaultLocale	Locale value
    * @param ContainerInterface $container      The container service
    */   
   public function __construct(ContainerInterface $container, $defaultLocale = 'en')
   {
       $this->defaultLocale = $defaultLocale;   
       $this->container     = $container;  
   }

   /**
    * Invoked to modify the controller that should be executed.
    *
    * @param GetResponseEvent $event The event
    * 
    * @access public
    * @return null|void
    */   
   public function onKernelRequest(GetResponseEvent $event)
   {
       if (HttpKernel::MASTER_REQUEST != $event->getRequestType()) {
           // ne rien faire si ce n'est pas la requête principale
           return;
       }       
       $this->request = $event->getRequest($event);
       //if (!$this->request->hasPreviousSession()) {
       //    return;
       //}
           
       // we set locale
       $locale = $this->request->cookies->has('_locale');
       $localevalue = $this->request->cookies->get('_locale');
       $is_switch_language_browser_authorized = $this->container->getParameter('switch_language_authorized');
       $all_locales                           = $this->container->getParameter('all_locales');
       // Sets the user local value.
       if ($is_switch_language_browser_authorized && !$locale) {
           $lang_value  = $this->container->get('request')->getPreferredLanguage();
           if (in_array($lang_value, $all_locales)) {
               $this->request->setLocale($lang_value);
               $_GET['_locale'] = $lang_value;

               return;
           }
       }
       if ($locale && !empty($localevalue)) {
           $this->request->attributes->set('_locale', $localevalue);
           $this->request->setLocale($localevalue);
           $_GET['_locale'] = $localevalue;
       } else {
           $this->request->attributes->set('_locale', $this->defaultLocale);
           $this->request->setLocale($this->defaultLocale);
           $_GET['_locale'] = $this->defaultLocale;   
       }
   }
}
