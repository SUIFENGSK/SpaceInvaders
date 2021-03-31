class Missile
{
    float x, y;
    float missileSpeed;
    String type;
    Pic playerMissile = new Pic("PlayerMissile");
    Pic enemyMissile = new Pic("EnemyMissile");
    Missile(float x, float y, String type)
    {
        this.x = x;
        this.type = type;
        if (type == "PLAYER")
        {
            missileSpeed = 10;
            this.y = y - 10;
        }
        if (type == "ENEMY") 
        {
            missileSpeed =- 10;
            this.y = y + 10;
        }
    }
    void Launch()
    {
        if (type == "PLAYER")
        {
            imageMode(CENTER);
            playerMissile.display(x, y, 20, 30);
        }
        if (type == "ENEMY")
        {
            imageMode(CENTER);
            enemyMissile.display(x, y, 20, 30);
        }
        y -=missileSpeed;
    }
}
