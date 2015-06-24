<?php
namespace Dirisi\AuthBundle\Handler;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Http\Authentication\DefaultAuthenticationSuccessHandler;
use Symfony\Component\Security\Http\HttpUtils;
use Symfony\Component\HttpFoundation\Cookie;
use Symfony\Component\Security\Core\SecurityContext;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\Routing\Router;

class AuthenticationSuccessHandler extends DefaultAuthenticationSuccessHandler 
{
    private $security;
    private $router;
    
    public function __construct(
            Router $router, 
            SecurityContext $security, 
            HttpUtils $httpUtils, 
            array $options
    ) {
        parent::__construct( $httpUtils, $options );
        
        $this->security = $security;
        $this->router   = $router;
    }

    public function onAuthenticationSuccess( Request $request, TokenInterface $token ) {
        if( $request->isXmlHttpRequest() ) {
            $response = new JsonResponse(array('success' => true, 'username' => $token->getUsername()));
        } else {
            if ($this->security->isGranted('ROLE_SUPER_ADMIN')) {
                $response = new RedirectResponse($this->router->generate('dirisi_admin_user'));			
            } elseif ($this->security->isGranted('ROLE_USER')) {
                // redirect the user to where they were before the login process begun.
                $referer_url = $request->headers->get('referer');

                $response = new RedirectResponse($referer_url);
            } else {
                $response = parent::onAuthenticationSuccess( $request, $token);   
            }
        }			
        $response->headers->setCookie(new Cookie('succes_connexion', $token->getUsername(), 0));
                
        return $response;
    }
}
