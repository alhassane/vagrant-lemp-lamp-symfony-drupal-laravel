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

    public function saveFormProcess(Film $entity, $data, $type = 'default') 
    {       
        $id = $entity->getId();
        if (isset($id) && !empty($id)) {
            if ($type == 'default') {
                $entity->setTitre($data->getTitre());
                $entity->setDescription($data->getDescription());
                $entity->setCategorie($data->getCategorie());
                $entity->setActeurs($data->getActeurs());
            }
            
////both arrays will be merged including duplicates
//$result = array_merge( $array1, $array2 );
////duplicate objects will be removed
//$result = array_map("unserialize", array_unique(array_map("serialize", $result)));
////array is sorted on the bases of id
//sort( $result );
//
//
//array_map('unserialize', array_intersect(array_map('serialize', $obj1), array_map('serialize', $obj2)) );            
            
            $message = $this->container->get('translator')->trans('film.modifier.succes',array(
                        '%titre%' => $entity->getTitre()
                        ));
        } else {
            $message = $this->container->get('translator')->trans('film.ajouter.succes',array(
                        '%titre%' => $data->getTitre()
                        ));
            $entity = $data;
        }        
        $this->em->getRepository('DirisiWebsiteBundle:Film')->save($entity);
            
        return $message;
    }
}
