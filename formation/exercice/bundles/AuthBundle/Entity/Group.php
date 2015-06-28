<?php

namespace Dirisi\AuthBundle\Entity;
use FOS\UserBundle\Model\Group as BaseGroup;

use Doctrine\ORM\Mapping as ORM;

/**
 * Group
 *
 * @ORM\Table(name="fos_group")
 * @ORM\Entity(repositoryClass="Dirisi\AuthBundle\Entity\GroupRepository")
 */
class Group extends BaseGroup
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="created_at", type="datetime")
     */
    protected $created_at;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="updated_at_at", type="datetime")
     */
    protected $updated_at_at;

    /**
     * @var \DateTime
     *
     * @ORM\Column(name="archive_at", type="datetime")
     */
    protected $archive_at;

    /**
     * @var boolean
     *
     * @ORM\Column(name="enabled", type="boolean")
     */
    protected $enabled;


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
     * Set createdAt
     *
     * @param \DateTime $createdAt
     *
     * @return Group
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
     * @return Group
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
     * @return Group
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

    /**
     * Set enabled
     *
     * @param boolean $enabled
     *
     * @return Group
     */
    public function setEnabled($enabled)
    {
        $this->enabled = $enabled;

        return $this;
    }

    /**
     * Get enabled
     *
     * @return boolean
     */
    public function getEnabled()
    {
        return $this->enabled;
    }
}

