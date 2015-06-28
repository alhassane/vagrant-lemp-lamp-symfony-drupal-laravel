<?php

namespace Dirisi\AuthBundle\Form;
use Symfony\Component\Validator\Constraints;
use Doctrine\ORM\EntityRepository;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class UserType extends AbstractType
{
    /**
     * @param FormBuilderInterface $builder
     * @param array $options
     */
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('groups')
            ->add('name')
            ->add('username')
            ->add('groups','entity', array(
                    'label' => 'pi.form.label.field.usergroup',
                    'class' => 'AcmeAuthBundle:Group',
                    'query_builder' => function(EntityRepository $er) {
                            return $er->createQueryBuilder('k')
                            ->select('k')
                            ->where('k.enabled = :enabled')
                            ->orderBy('k.name', 'ASC')
                            ->setParameter('enabled', 1);
                    },
                    'property' => 'name',
                    'multiple'	=> true,
                    'expanded'  => false,
                    'required'  => false,
            ))
            ->add('plainPassword', 'repeated', array(
                    'type' => 'password',
                    'options' => array('translation_domain' => 'FOSUserBundle'),
                    'first_options' => array('label' => 'form.password'),
                    'second_options' => array('label' => 'form.password_confirmation'),
                    'invalid_message' => 'fos_user.password.mismatch',
                    'constraints' => array(
                        new Constraints\NotBlank(),
                    ),
            ))
            ->add('email')
            ->add('nickname')
            ->add('birthday')
            ->add('address')
            ->add('zip_code')
            ->add('city')
            ->add('country')
            ->add('created_at')
            ->add('updated_at_at')
            ->add('archive_at')
        ;
    }
    
    /**
     * @param OptionsResolverInterface $resolver
     */
    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => 'Dirisi\AuthBundle\Entity\User'
        ));
    }

    /**
     * @return string
     */
    public function getName()
    {
        return 'dirisi_authbundle_user';
    }
}
