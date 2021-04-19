class Missile
{
    public float x, y;
    public float missileSpeed;
    private String type;
    private Pic playerMissile = new Pic("PlayerMissile"); //Read and import the player’s missile picture
    private Pic enemyMissile = new Pic("EnemyMissile"); //Read and import enemy's missile pictures
    public Missile(float x, float y, String type)
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
    public void Launch()
    {
        if (type == "PLAYER")
        {
            imageMode(CENTER);
            playerMissile.Display(x, y, 20, 30); //Display missile image
        }
        if (type == "ENEMY")
        {
            imageMode(CENTER);
            enemyMissile.Display(x, y, 20, 30); //Display missile image
        }
        y -=missileSpeed; //Change the position of the missile
    }
}
