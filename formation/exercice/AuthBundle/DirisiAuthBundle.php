<?php

namespace Dirisi\AuthBundle;

use Symfony\Component\HttpKernel\Bundle\Bundle;

class DirisiAuthBundle extends Bundle
{


    public function getParent()
    {
        return 'FOSUserBundle';
    }

}
