<?php
namespace Dirisi\WebsiteBundle\Form\Handler;

interface FormHandlerInterface
{
    /**
     * The process function should bind the form, check if it is valid
     * and do any post treatment (persisting the entity etc.)
     *
     * @return Boolean False to notify that postprocessing could not be executed.
     *                 This can be the case when the form is not valid, the request method
     *                 not supported etc.
     */
    public function process();
}
