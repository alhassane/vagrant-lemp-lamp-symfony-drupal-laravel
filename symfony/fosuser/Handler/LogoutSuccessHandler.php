<?php
namespace Dirisi\AuthBundle\Handler;
 
use Symfony\Component\Security\Http\Logout\LogoutHandlerInterface;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Cookie;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Bundle\FrameworkBundle\Routing\Router;
use Doctrine\ORM\EntityManager;
 
class LogoutSuccessHandler implements LogoutHandlerInterface
{
        /**
         * @var EntityManager
         */
        protected $em;
    
	protected $router;
	
	public function __construct(Router $router, EntityManager $em)
	{
            $this->router = $router;
            $this->em = $em;
	}
	
	public function logout(Request $request, Response $response, TokenInterface $token)
	{
            $user = $token->getUser();
            
            // do stuff with the user object...
            // $this->em->persist($user);
            $this->em->flush();
            
            // redirect the user to where they were before the login process begun.
            //$referer_url = $request->headers->get('referer');
            //$response = new RedirectResponse($referer_url);
            
            $response->headers->setCookie(new Cookie('succes_connexion', 'coincoin', time() - 3600));
            
            return $response;
	}	
}
