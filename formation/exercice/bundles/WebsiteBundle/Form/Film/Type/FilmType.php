<?php

namespace Dirisi\WebsiteBundle\Form\Film\Type;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;
use Dirisi\WebsiteBundle\Form\ActeurForm;

class FilmType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {        
        $builder
                ->add('id', 'hidden')
                ->add('titre', 'text', array('label' => 'film.titre'))
                ->add('description', 'textarea', array('label' => 'film.description'));
        
        if (!empty($options)) {
            print_r(intval($options['category_hidden']));
            if (!$options['category_hidden']) {
                $builder->add('categorie','entity', array(
                    'class' => 'Dirisi\WebsiteBundle\Entity\Categorie',
                    'property' => 'nom',
                    'multiple' => false,
                    'required' => false,
                    'label' => 'film.categorie'
                )); 
            }
        }

        $builder->add('acteurs', 'entity', array(
            'class' => 'Dirisi\WebsiteBundle\Entity\Acteur',
            'property' => 'PrenomNom',
            'expanded' => true,
            'multiple' => true,
            'required' => false,
            'label' => 'film.acteurs'
            ));
    }
    public function getName()
    {
        return 'dirisi_website_film';
    }
    
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
                'data_class' => 'Dirisi\WebsiteBundle\Entity\Film',
                'category_hidden' => true,
        ));
    }       
}