class Player
{
    float x = width / 2;
    float y = height * 7 / 8;
    float moveSpeed = 10;
    float playerSize;
    int time = 0;
    int lastTime = 0;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic playerShipImg;
    int missileUpgrade = 0;
    String controllerMode;
    Player(float playerSize, String shipName, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic(shipName);
    }
    Player(float playerSize, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic("PlayerShip01");
    }
    void Display()
    {
        imageMode(CENTER);
        playerShipImg.display(x, y, playerSize, playerSize);
        if(controllerMode.equals("Keyboard Mode")) KeyboardMove();
        if(controllerMode.equals("Mouse Mode")) MouseMove();
        MissileLaunch();
    }
    void KeyboardMove()
    {
        if (keyPressed && keyCode == UP) 
        {
            y -=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == DOWN) 
        {
            y +=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == LEFT) 
        {
            x -=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == RIGHT) 
        {
            x +=moveSpeed;
            keyCode = 0;
        }
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    void MouseMove()
    {
        x=mouseX;
        y=mouseY;
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    void MissileLaunch()
    {
        time = millis() - lastTime;
        if (missileUpgrade > 500) missileUpgrade = 500;
        if (time > 700 - missileUpgrade) {
            lastTime = millis();
            missile.add(new Missile(x, y, "PLAYER"));
        }
        /*
        if (keyPressed && key==' ') 
    {
        key=0;
        missile.add(new Missile(x, y, "PLAYER"));
    }
        */
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch();
                if (missile.get(i).y<0) 
                {
                    missile.remove(i);
                }
            }
        }
        //println(missile.size());
    }
}
