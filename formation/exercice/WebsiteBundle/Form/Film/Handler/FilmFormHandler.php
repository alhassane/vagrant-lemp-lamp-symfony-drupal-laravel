<?php
namespace Dirisi\WebsiteBundle\Form\Film\Handler;

use Symfony\Component\Form\FormInterface;
use Symfony\Component\HttpFoundation\Request;
use Dirisi\WebsiteBundle\Form\Handler\AbstractFormHandler;
use Dirisi\WebsiteBundle\Manager\FilmManager;

class FilmFormHandler extends AbstractFormHandler
{
    private $message = "";
    
    public function __construct(FormInterface $form, FilmManager $processManager, Request $request) {
        parent::__construct($form, $request, $processManager);      
    }

    protected function getValidMethods()
    {
        return array('POST');
    }
  
    protected function onSuccess()
    {
        $this->message = $this->processManager->saveFormProcess($this->obj, $this->form->getData(), 'default');
        
        return true;
    }
    
    public function getMessage() {
        return $this->message;
    }
}
