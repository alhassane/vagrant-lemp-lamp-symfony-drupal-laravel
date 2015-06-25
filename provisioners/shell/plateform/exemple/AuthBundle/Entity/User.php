<?php

namespace Dirisi\AuthBundle\Entity;
use FOS\UserBundle\Model\User as AbstractUser;

use Doctrine\ORM\Mapping as ORM;

/**
 * User
 *
 * @ORM\Table(name="fos_user")
 * @ORM\Entity(repositoryClass="Dirisi\AuthBundle\Entity\UserRepository")
 */
class User extends AbstractUser
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer", nullable=true)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @var array
     *
     * @ORM\Column(name="groups", type="array", nullable=true)
     */
    protected $groups;

    /**
     * @var string
     *
     * @ORM\Column(name="name", type="string", length=50, nullable=true)
     */
    protected $name;

    /**
     * @var string
     *
     * @ORM\Column(name="nickname", type="string", length=50, nullable=true)
     */
    protected $nickname;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="birthday", type="datetime", nullable=true)
     */
    protected $birthday;

    /**
     * @var string
     *
     * @ORM\Column(name="address", type="text", nullable=true)
     */
    protected $address;

    /**
     * @var string
     *
     * @ORM\Column(name="zip_code", type="string", length=6, nullable=true)
     */
    protected $zip_code;

    /**
     * @var string
     *
     * @ORM\Column(name="city", type="string", length=50, nullable=true)
     */
    protected $city;

    /**
     * @var string
     *
     * @ORM\Column(name="country", type="string", length=50, nullable=true)
     */
    protected $country;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="created_at", type="datetime", nullable=true)
     */
    protected $created_at;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="updated_at_at", type="datetime", nullable=true)
     */
    protected $updated_at_at;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="archive_at", type="datetime", nullable=true)
     */
    protected $archive_at;


    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set groups
     *
     * @param array $groups
     *
     * @return User
     */
    public function setGroups($groups)
    {
        $this->groups = $groups;

        return $this;
    }

    /**
     * Get groups
     *
     * @return array
     */
    public function getGroups()
    {
        return parent::getGroups();
    }

    /**
     * Set name
     *
     * @param string $name
     *
     * @return User
     */
    public function setName($name)
    {
        $this->name = $name;

        return $this;
    }

    /**
     * Get name
     *
     * @return string
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * Set nickname
     *
     * @param string $nickname
     *
     * @return User
     */
    public function setNickname($nickname)
    {
        $this->nickname = $nickname;

        return $this;
    }

    /**
     * Get nickname
     *
     * @return string
     */
    public function getNickname()
    {
        return $this->nickname;
    }

    /**
     * Set birthday
     *
     * @param \DateTime $birthday
     *
     * @return User
     */
    public function setBirthday($birthday)
    {
        $this->birthday = $birthday;

        return $this;
    }

    /**
     * Get birthday
     *
     * @return \DateTime
     */
    public function getBirthday()
    {
        return $this->birthday;
    }

    /**
     * Set address
     *
     * @param string $address
     *
     * @return User
     */
    public function setAddress($address)
    {
        $this->address = $address;

        return $this;
    }

    /**
     * Get address
     *
     * @return string
     */
    public function getAddress()
    {
        return $this->address;
    }

    /**
     * Set zipCode
     *
     * @param string $zipCode
     *
     * @return User
     */
    public function setZipCode($zipCode)
    {
        $this->zip_code = $zipCode;

        return $this;
    }

    /**
     * Get zipCode
     *
     * @return string
     */
    public function getZipCode()
    {
        return $this->zip_code;
    }

    /**
     * Set city
     *
     * @param string $city
     *
     * @return User
     */
    public function setCity($city)
    {
        $this->city = $city;

        return $this;
    }

    /**
     * Get city
     *
     * @return string
     */
    public function getCity()
    {
        return $this->city;
    }

    /**
     * Set country
     *
     * @param string $country
     *
     * @return User
     */
    public function setCountry($country)
    {
        $this->country = $country;

        return $this;
    }

    /**
     * Get country
     *
     * @return string
     */
    public function getCountry()
    {
        return $this->country;
    }

    /**
     * Set createdAt
     *
     * @param \DateTime $createdAt
     *
     * @return User
     */
    public function setCreatedAt($createdAt)
    {
        $this->created_at = $createdAt;

        return $this;
    }

    /**
     * Get createdAt
     *
     * @return \DateTime
     */
    public function getCreatedAt()
    {
        return $this->created_at;
    }

    /**
     * Set updatedAtAt
     *
     * @param \DateTime $updatedAtAt
     *
     * @return User
     */
    public function setUpdatedAtAt($updatedAtAt)
    {
        $this->updated_at_at = $updatedAtAt;

        return $this;
    }

    /**
     * Get updatedAtAt
     *
     * @return \DateTime
     */
    public function getUpdatedAtAt()
    {
        return $this->updated_at_at;
    }

    /**
     * Set archiveAt
     *
     * @param \DateTime $archiveAt
     *
     * @return User
     */
    public function setArchiveAt($archiveAt)
    {
        $this->archive_at = $archiveAt;

        return $this;
    }

    /**
     * Get archiveAt
     *
     * @return \DateTime
     */
    public function getArchiveAt()
    {
        return $this->archive_at;
    }
}

