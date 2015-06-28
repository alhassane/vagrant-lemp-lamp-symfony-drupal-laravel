<?php
namespace Dirisi\WebsiteBundle\Manager;

use Dirisi\WebsiteBundle\Entity\Film;
use Doctrine\ORM\EntityManager;
use Symfony\Component\DependencyInjection\ContainerInterface;

class FilmManager
{
    /**
     * @var ContainerInterface
     */
    protected $container;   
   
    /**
     * @var EntityManager
     */
    protected $em;   
   
    /**
     * @var Translator
     */    
    protected $translator;   

    /**
     * Constructor.
     *
     * @param Translator         $translator Service of translation
     * @param EntityManager      $em	     Entity manager service
     * @param ContainerInterface $container  The container of services
     */   
    public function __construct($translator, EntityManager $em, ContainerInterface $container)
    {
        $this->translator = $translator; 
        $this->em = $em;   
        $this->container = $container;  
    }

    public function saveFormProcess($entity) 
    {       
        $id = $entity->getId();
        if (isset($id) && !empty($id)) {
            $message = $this->container->get('translator')
                    ->trans('film.modifier.succes',array(
                        '%titre%' => $entity->getTitre()
                    ));
        } else {
            $message = $this->container->get('translator')
                    ->trans('film.ajouter.succes',array(
                        '%titre%' => $entity->getTitre()
                    ));
        }        
        $this->em->getRepository('DirisiWebsiteBundle:Film')->saveByMerge($entity);
            
        return $message;
    }
    
    public function remove($entity) {
        $this->em->getRepository('DirisiWebsiteBundle:Film')->remove($entity);
    }
}
