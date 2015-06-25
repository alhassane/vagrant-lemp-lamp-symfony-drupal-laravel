<?php

namespace Dirisi\WebsiteBundle\Entity;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

/**
 * @ORM\Entity
 */
class Film
{
    /**
     * @ORM\GeneratedValue
     * @ORM\Id
     * @ORM\Column(type="integer")
     */
    private $id;
    
    /**
     * @ORM\Column(type="string",length=255)
     * @Assert\NotBlank()
     * @Assert\Length(min = 3)
     */    
    private $titre;

    /**
     * @ORM\Column(type="string",length=500)
     */    
    private $description;

    /**
     * @ORM\ManyToOne(targetEntity="Categorie")
     * @Assert\NotBlank()
     */    
    private $categorie;

    /**
     * @ORM\ManyToMany(targetEntity="Acteur")
     */    
    private $acteurs;

    public function __construct()
    {
        $this->acteurs = new \Doctrine\Common\Collections\ArrayCollection();
    }
    
    /**
     * Get id
     *
     * @return integer $id
     */
    public function getId()
    {
        return $this->id;
    }
    
    /**
     * Get id
     *
     * @return integer $id
     */
    public function setId($id)
    {
        $this->id = $id;
    }    

    /**
     * Set titre
     *
     * @param string $titre
     */
    public function setTitre($titre)
    {
        $this->titre = $titre;
    }

    /**
     * Get titre
     *
     * @return string $titre
     */
    public function getTitre()
    {
        return $this->titre;
    }

    /**
     * Set description
     *
     * @param string $description
     */
    public function setDescription($description)
    {
        $this->description = $description;
    }

    /**
     * Get description
     *
     * @return string $description
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * Set categorie
     *
     * @param Dirisi\WebsiteBundle\Entity\Categorie $categorie
     */
    public function setCategorie(\Dirisi\WebsiteBundle\Entity\Categorie $categorie)
    {
        $this->categorie = $categorie;
    }

    /**
     * Get categorie
     *
     * @return Dirisi\WebsiteBundle\Entity\Categorie $categorie
     */
    public function getCategorie()
    {
        return $this->categorie;
    }

    /**
     * Add acteurs
     *
     * @param Dirisi\WebsiteBundle\Entity\Acteur $acteurs
     */
    public function addActeurs(\Dirisi\WebsiteBundle\Entity\Acteur $acteurs)
    {
        $this->acteurs[] = $acteurs;
    }

    /**
     * Get acteurs
     *
     * @return Doctrine\Common\Collections\Collection $acteurs
     */
    public function getActeurs()
    {
        return $this->acteurs;
    }
    
    public function setActeurs($acteurs) {
        $this->acteurs = $acteurs;
    }
}
