<?php
namespace Dirisi\WebsiteBundle\Form\Handler;

use Symfony\Component\Form\FormInterface;
use Symfony\Component\HttpFoundation\Request;

abstract class AbstractFormHandler implements FormHandlerInterface
{
    /**
     * @var FormInterface
     */
    protected $form;
    
    /**
     * @var Request
     */    
    protected $request;
    
    /**
     * @var
     */      
    protected $processHandler;
    
    /**
     * @var Object
     */      
    protected $obj;    

    public function __construct(FormInterface $form, Request $request, $processHandler = null)
    {
        $this->form = $form;
        $this->request = $request;
        $this->processHandler = $processHandler;
    }

    /**
     * @return array Accepted request methods
     */
    abstract protected function getValidMethods();

    /**
     * This method implements the post-processing if the form is bound and valid.
     * The return value will be available as process() return (should be falsy on failure)
     *
     * @return mixed
     */
    abstract protected function onSuccess();

    /**
     * Validates if the request can be accepted
     */
    protected function validateRequest()
    {
        return array_search($this->request->getMethod(), $this->getValidMethods()) !== false;
    }

    /**
     * {@inheritdoc}
     */
    public function process()
    {
        if ($this->validateRequest()) {
            $this->form->handleRequest($this->request);
            
            if ($this->form->isValid()) {
                return $this->onSuccess();
            }            
        }

        return false;
    }

    /**
     * Returns the current form
     *
     * @return Symfony\Component\Form\Form
     */
    public function getForm()
    {
        return $this->form;
    }
    
    /**
     * Set object
     *
     * @param string $obj
     */
    public function setObject($obj)
    {
        $this->obj = $obj;
        
        return $this;
    }  
    
    /**
     * Get object
     */
    public function getObject()
    {
        return $this->obj;
    }        
}
