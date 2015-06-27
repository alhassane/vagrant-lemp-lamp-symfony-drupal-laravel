<?php

namespace Dirisi\WebsiteBundle\Controller;

use Symfony\Component\DependencyInjection\ContainerAware;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Dirisi\WebsiteBundle\Entity\Film;
use Dirisi\WebsiteBundle\Form\FilmForm;
use Dirisi\WebsiteBundle\Form\Film\Type\FilmType;

class FilmController extends ContainerAware
{
    public function listerAction()
    {        
        $em = $this->container->get('doctrine')->getEntityManager();
        $films = $em->getRepository('DirisiWebsiteBundle:Film')->findAll();

        return $this->container->get('templating')->renderResponse('DirisiWebsiteBundle:Film:lister.html.twig', array(
            'films' => $films
        ));
    }
    
    public function topAction($max = 5)
    {
        $em = $this->container->get('doctrine')->getEntityManager();

        $qb = $em->createQueryBuilder();
        $qb->select('f')
          ->from('DirisiWebsiteBundle:Film', 'f')
          ->orderBy('f.titre', 'ASC')
          ->setMaxResults($max);
        
        $query = $qb->getQuery();
        $films = $query->getResult();

        return $this->container->get('templating')->renderResponse('DirisiWebsiteBundle:Film:liste.html.twig', array(
            'films' => $films,
        ));
    }

    public function voirAction($id = null)
    {
        $em = $this->container->get('doctrine')->getEntityManager();

        if (isset($id)) 
        {
            $film = $em->find('DirisiWebsiteBundle:Film', $id);
        }            

        return $this->container->get('templating')->renderResponse(
        'DirisiWebsiteBundle:Film:voir.html.twig',
            array(
            'film' => $film,            
            )
        );
    }
    
    public function editerAction($id = null)
    {
        $message='';
        $em = $this->container->get('doctrine')->getEntityManager();

        if (isset($id)) 
        {
            $film = $em->find('DirisiWebsiteBundle:Film', $id);

            if (!$film)
            {
                $message='Aucun film trouvé';
            }
        }
        else 
        {
            $film = new Film();
        }

        
        // Get the Handler
        $formHandler = $this->container->get('dirisi.website.film.form.handler');
        // set process
        if ($formHandler->setObject($film)->process()) {
           $message = $formHandler->getMessage();
        }
        // Get the form
        $form = $formHandler->getForm();
        if ($this->container->get('request')->getMethod() != 'POST') {
            $form->setData($film);
        }
        
//        // Get the request
//        $request = $this->container->get('request');        
//        $form = $this->container->get('form.factory')->create(new FilmForm(), $film);
//
//        $request = $this->container->get('request');
//
//        if ($request->getMethod() == 'POST') 
//        {
//            $form->bind($request);
//
//            if ($form->isValid()) 
//            {
//                $em->persist($film);
//                $em->flush();
//                if (isset($id)) 
//                {
//                    $message = $this->container->get('translator')->trans('film.modifier.succes',array(
//                                '%titre%' => $film->getTitre()
//                                ));
//                } else  {
//                    $message = $this->container->get('translator')->trans('film.ajouter.succes',array(
//                                '%titre%' => $film->getTitre()
//                                ));
//                }
//            }
//        }

        return $this->container->get('templating')->renderResponse(
        'DirisiWebsiteBundle:Film:editer.html.twig',
            array(
            'form' => $form->createView(),
            'message' => $message,
            'film' => $film,
            'hasError' => $this->container->get('request')->getMethod() == 'POST' && !$form->isValid()
            )
        );
    }

    public function supprimerAction($id)
    {
        $em = $this->container->get('doctrine')->getEntityManager();
        $film = $em->find('DirisiWebsiteBundle:Film', $id);

        if (!$film) 
        {
            throw new NotFoundHttpException("Film non trouvé");
        }

        $em->remove($film);
        $em->flush();        


        return new RedirectResponse($this->container->get('router')->generate('dirisi_film_lister'));
    }
}