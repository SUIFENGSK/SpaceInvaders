class Player
{
    float x = width / 2; //Player's initial coordinates
    float y = height * 7 / 8;
    float moveSpeed = 10; //Player movement speed
    float playerSize;
    int time = 0;
    int lastTime = 0;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic playerShipImg; //Picture of the player's spaceship
    int missileUpgrade = 0; //The missile status of the player's spaceship
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
        playerShipImg.display(x, y, playerSize, playerSize); //Display player's spaceship
        if(controllerMode.equals("Keyboard Mode")) KeyboardMove(); //Keyboard mode
        if(controllerMode.equals("Mouse Mode")) MouseMove(); //Mouse mode
        MissileLaunch(); //The player fires a missile
    }
    void KeyboardMove()
    {
        //Direction judgment
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
        //Boundary judgment
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    void MouseMove()
    {
        x=mouseX;
        y=mouseY;
        //Boundary judgment
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    void MissileLaunch()
    {
        //Launch a missile every 700ms by default. With the upgrade of the player’s missiles, the missile’s launch speed can be as fast as 200ms per missile.
        time = millis() - lastTime;
        if (missileUpgrade > 500) missileUpgrade = 500;
        if (time > 700 - missileUpgrade) {
            lastTime = millis();
            missile.add(new Missile(x, y, "PLAYER")); //Add player's missile
        }
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch();  //Launch missile
                if (missile.get(i).y<0) 
                {
                    missile.remove(i); //If the missile coordinates are beyond the game interface, remove the missile
                }
            }
        }
    }
}
