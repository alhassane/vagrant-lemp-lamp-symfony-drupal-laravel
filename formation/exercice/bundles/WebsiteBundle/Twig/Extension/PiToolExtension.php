<?php
namespace Dirisi\WebsiteBundle\Twig\Extension;

use Symfony\Component\DependencyInjection\ContainerInterface;

class PiToolExtension extends \Twig_Extension
{
    /**
     * @var \Symfony\Component\DependencyInjection\ContainerInterface
     */
    protected $container;
    
    /**
     * Constructor.
     *
     * @param ContainerInterface $container The service container
     */
    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
    }
        
    /**
     * Returns the name of the extension.
     *
     * @return string The extension name
     * @access public
     */
    public function getName() {
        return 'dirisi_website_tool_extension';
    }
        
    /**
     * Returns a list of filters to add to the existing list.
     * 
     * @return array An array of filters
     * @access public
     */    
    public function getFilters() {
        return array(
            'myfirstfiltre'        => new \Twig_Filter_Method($this, 'myfiltre'),
        );
    }

    /**
     * Returns a list of functions to add to the existing list.
     * 
     * @return array An array of functions
     * @access public
     */
    public function getFunctions() {
        return array(
            'file_exists'             => new \Twig_Function_Function('file_exists'),
            'file_get_contents'       => new \Twig_Function_Function('file_get_contents'),
        );
    }   
     
    public function myfiltre($var, $prefix, $suffix) {
        return $prefix . strtolower($var) . $suffix;
    }
}
