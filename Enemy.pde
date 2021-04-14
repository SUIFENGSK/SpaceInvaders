class Enemy
{
    float enemySize;
    float x, y;
    float xSpeed = 3, ySpeed = 3; //Initialization speed of the enemy spaceship
    int time = 0;
    int lastTime = 0;
    boolean xyDirection, yMove = false, isDestroyed = false;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic enemyShipImg = new Pic("EnemyShip"); //Read and import enemy spaceship's picture
    Enemy(float y, float enemySize)
    {
        x = random(enemySize / 2 + 10, width - enemySize / 2 - 10); //Initialize the x-coordinate of the item randomly
        this.y = y; //Import the y-coordinate of the enemy spaceship
        this.enemySize = enemySize; //Import the size of the enemy spaceship
    }
    void Move()
    {
        if (!isDestroyed) //If the enemy spaceship is not destroyed, the enemy spaceship can move
        {
            time = millis() - lastTime;
            imageMode(CENTER);
            enemyShipImg.display(x,y,enemySize,enemySize); //Display enemy spaceship's picture
            if (time > 500) {//The enemy spaceship changes direction every 500ms
                lastTime = millis();
                //change y-direction. The probability of the enemy’s y-direction change depends on the degree of difficulty
                if (random(0, 1)<0.5 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.06) xyDirection = false; 
                //change x-direction
                else xyDirection = true; 
            }
            if (xyDirection) x += xSpeed;
            else if (yMove && !xyDirection) 
            {
                y +=ySpeed;
            } else
            {
                x +=xSpeed;
            }
            //If the enemy plane hits the left and right borders, it will bounce back
            if (x > width - enemySize / 2 || x < enemySize / 2) xSpeed =- xSpeed;
            if (x > width - enemySize / 2) x = width - enemySize / 2;
            if (x < enemySize / 2) x = enemySize / 2;
            if (y > 0 && y < height - 30) //Only enemy planes above 30 pixels of the bottom boundary are allowed to launch missiles
            {
                MissileAdd();
            }
        }
        MissileLaunch();        
    }
    void MissileAdd()
    {
        if (!isDestroyed && random(0, 1)<0.01 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.001) //The firing frequency of enemy missiles depends on the difficulty of the game
        {
            missile.add(new Missile(x, y, "ENEMY")); //Add enemy's missile
        }        
    }
    void MissileLaunch()
    {
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch(); //Launch missile
                if (missile.get(i).y>height) 
                {
                    missile.remove(i); //If the missile coordinates are beyond the game interface, remove the missile
                }
            }
        }
    }
}
