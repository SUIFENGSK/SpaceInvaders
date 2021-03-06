class Item
{
    public float itemSize = 30;
    public float x, y;
    private float ySpeed = 3; //Item's falling speed
    private Pic itemImg; //Picture of the item
    public String itemType;
    public Item(float randomNum)
    {
        x = random(itemSize / 2 + 10, width - itemSize / 2 - 10); //Initialize the x-coordinate of the item randomly
        y = 0;
        if (randomNum < 0.45) //There is a 45 percent chance of getting an extra life
        {
            itemImg = new Pic("LifeUp");
            itemType = "LifeUp";
        }
        if (randomNum >= 0.45 && randomNum < 0.9) //There is a 45 percent chance of increasing missile firing rate
        {
            itemImg = new Pic("MissileUp");
            itemType = "MissileUp";
        }
        
        if (randomNum >=0.9) //There is a 10 percent chance of clearing all enemies in the current screen
        {
            itemImg = new Pic("UniqueSkill");
            itemType = "UniqueSkill";
        }
    }
    public void Move()
    {
        imageMode(CENTER);
        itemImg.Display(x,y,itemSize,itemSize); //Show the picture of the item
        y +=ySpeed; //Item moves
    }
}