<?php
namespace Dirisi\WebsiteBundle\Handler;

use Dirisi\WebsiteBundle\Entity\Film;
use Doctrine\ORM\EntityManager;
use Symfony\Component\DependencyInjection\ContainerInterface;

class FilmHandlerProcess
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

    public function save(Film $entity, $data, $type = 'default') 
    {       
        $id = $entity->getId();
        if (isset($id) && !empty($id)) {
            if ($type == 'default') {
                $entity->setTitre($data->getTitre());
                $entity->setDescription($data->getDescription());
                $entity->setCategorie($data->getCategorie());
                $entity->setActeurs($data->getActeurs());
            }
            
            $message = $this->container->get('translator')->trans('film.modifier.succes',array(
                        '%titre%' => $entity->getTitre()
                        ));
        } else {
            $message = $this->container->get('translator')->trans('film.ajouter.succes',array(
                        '%titre%' => $data->getTitre()
                        ));
            $entity = $data;
        }
        
        // we create/modify entity
        $this->em->persist($entity);
        $this->em->flush();
            
        return $message;
    }
}
