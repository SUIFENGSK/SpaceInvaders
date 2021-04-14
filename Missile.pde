class Missile
{
    float x, y;
    float missileSpeed;
    String type;
    Pic playerMissile = new Pic("PlayerMissile"); //Read and import the player’s missile picture
    Pic enemyMissile = new Pic("EnemyMissile"); //Read and import enemy's missile pictures
    Missile(float x, float y, String type)
    {
        this.x = x;
        this.type = type;
        if (type == "PLAYER") //Player's missile speed and initial position
        {
            missileSpeed = 10;
            this.y = y - 10;
        }
        if (type == "ENEMY") //Enemy's missile speed and initial position
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
            playerMissile.display(x, y, 20, 30); //Display missile image
        }
        if (type == "ENEMY")
        {
            imageMode(CENTER);
            enemyMissile.display(x, y, 20, 30); //Display missile image
        }
        y -=missileSpeed; //Change the position of the missile
    }
}
