class Enemy
{
    float enemySize;
    float x, y;
    float xSpeed = 3, ySpeed = 3;
    int time = 0;
    int lastTime = 0;
    boolean xyDirection, yMove = false, isDestroyed = false;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic enemyShipImg = new Pic("EnemyShip");
    Enemy(float y, float enemySize)
    {
        x = random(enemySize / 2 + 10, width - enemySize / 2 - 10);
        this.y = y;
        this.enemySize = enemySize;
    }
    void Move()
    {
        if (!isDestroyed) 
        {
            time = millis() - lastTime;
            imageMode(CENTER);
            enemyShipImg.display(x,y,enemySize,enemySize);
            if (time > 500) {
                lastTime = millis();
                if (random(0, 1)<0.5 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.06) xyDirection = false; //y-direction
                else xyDirection = true; //x-direction
            }
            if (xyDirection) x += xSpeed;
            else if (yMove && !xyDirection) 
            {
                y +=ySpeed;
            } else
            {
                x +=xSpeed;
            }
            //println(x);
            if (x > width - enemySize / 2 || x < enemySize / 2) xSpeed =- xSpeed;
            if (x > width - enemySize / 2) x = width - enemySize / 2;
            if (x < enemySize / 2) x = enemySize / 2;
            if (y > 0 && y < height - 30) 
            {
                MissileAdd();
            }
        }
        MissileLaunch();
        
    }
    void MissileAdd()
    {
        if (!isDestroyed && random(0, 1)<0.01 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.001) 
        {
            missile.add(new Missile(x, y, "ENEMY"));
        }        
    }
    void MissileLaunch()
    {
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch();
                if (missile.get(i).y>height) 
                {
                    missile.remove(i);
                }
            }
        }
        //println(missile.size());F
    }
}
