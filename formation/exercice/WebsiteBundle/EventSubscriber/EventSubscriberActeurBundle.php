<?php

namespace Dirisi\WebsiteBundle\EventSubscriber;

use Doctrine\Common\EventSubscriber;
use Doctrine\Common\EventArgs;
use Doctrine\ORM\Events;
use Doctrine\ORM\Event\PreUpdateEventArgs;
use Symfony\Component\DependencyInjection\ContainerInterface;

class EventSubscriberActeurBundle  implements EventSubscriber
{
    /**
     * @return array
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function getSubscribedEvents()
    {
        return array(
            Events::prePersist,
            Events::preUpdate,
            Events::preRemove,
            Events::postUpdate,
            Events::postRemove,
            Events::postPersist,
        );
    }

    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    protected function recomputeSingleEntityChangeSet(EventArgs $args)
    {
        $em = $args->getEntityManager();

        $em->getUnitOfWork()->recomputeSingleEntityChangeSet(
            $em->getClassMetadata(get_class($args->getEntity())),
            $args->getEntity()
        );
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function postUpdate(EventArgs $eventArgs)
    {
       	$entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function postRemove(EventArgs $eventArgs)
    {
    	$entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function postPersist(EventArgs $eventArgs)
    {
    	$entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function preUpdate(PreUpdateEventArgs $eventArgs)
    {
        $entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function preRemove(EventArgs $eventArgs)
    {
        $entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    }
    
    /**
     * @param \Doctrine\Common\EventArgs $args
     * @return void
     * 
     * @author Etienne de Longeaux <etienne.delongeaux@gmail.com>
     */
    public function prePersist(EventArgs $eventArgs)
    {
        $entity			= $eventArgs->getEntity();
    	$entityManager 	= $eventArgs->getEntityManager();
    } 
}
