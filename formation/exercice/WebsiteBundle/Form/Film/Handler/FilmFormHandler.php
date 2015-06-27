<?php
namespace Dirisi\WebsiteBundle\Form\Film\Handler;

use Symfony\Component\Form\FormInterface;
use Symfony\Component\HttpFoundation\Request;
use Dirisi\WebsiteBundle\Form\Handler\AbstractFormHandler;
use Dirisi\WebsiteBundle\Handler\FilmHandlerProcess;

class FilmFormHandler extends AbstractFormHandler
{
    private $message = "";
    
    public function __construct(FormInterface $form, FilmHandlerProcess $processHandler, Request $request) {
        parent::__construct($form, $request, $processHandler);      
    }

    protected function getValidMethods()
    {
        return array('POST');
    }
  
    protected function onSuccess()
    {
        $this->message = $this->processHandler->save($this->obj, $this->form->getData(), 'default');
        
        return true;
    }
    
    public function getMessage() {
        return $this->message;
    }
}
