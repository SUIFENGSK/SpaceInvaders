class Item
{
    float itemSize = 30;
    float x, y;
    float ySpeed = 3;
    Pic itemImg;
    boolean status = false;
    String itemType;
    Item(float randomNum)
    {
        x = random(itemSize / 2 + 10, width - itemSize / 2 - 10);
        y = 0;
        if (randomNum < 0.45) 
        {
            itemImg = new Pic("LifeUp");
            itemType = "LifeUp";
        }
        if (randomNum >= 0.45 && randomNum < 0.9) 
        {
            itemImg = new Pic("MissileUp");
            itemType = "MissileUp";
        }
        
        if (randomNum >=0.9) 
        {
            itemImg = new Pic("UniqueSkill");
            itemType = "UniqueSkill";
        }
    }
    void Move()
    {
        imageMode(CENTER);
        itemImg.display(x,y,itemSize,itemSize);
        y +=ySpeed;
    }
}