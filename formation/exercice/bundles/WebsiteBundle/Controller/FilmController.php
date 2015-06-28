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
        $films = $em->getRepository('DirisiWebsiteBundle:Film')->allOrderByTitle($max);

        return $this->container->get('templating')->renderResponse('DirisiWebsiteBundle:Film:liste.html.twig', array(
            'films' => $films,
        ));
    }

    public function voirAction(Film $film)
    {
        return $this->container->get('templating')->renderResponse(
        'DirisiWebsiteBundle:Film:voir.html.twig',
            array(
            'film' => $film,            
            )
        );
    }
    
    public function editerAction(Film $film = null)
    {
        $message='';
        // we create entity if not exists in databse
        if (isset($film)) {
            if (!$film) {
                $message='Aucun film trouvé';
            }
        } else {
            $film = new Film();
        }
        // We get the Handler
        $formHandler = $this->container->get('dirisi.website.film.form.handler');
        // set process
        if ($formHandler->process()) {
           $message = $formHandler->getMessage();
        }
        // We get the form
        $form = $formHandler->getForm();
        if ($this->container->get('request')->getMethod() != 'POST') {
            $form->setData($film); # this is necessary to view data in update mode
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

    public function supprimerAction(Film $film)
    {
        $this->container->get('dirisi.process.manager.film')->remove($film);

        return new RedirectResponse($this->container->get('router')->generate('dirisi_film_lister'));
    }
}
