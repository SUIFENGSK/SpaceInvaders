import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.utils.*;
import gifAnimation.*;
import processing.sound.*;
Gif spaceAnimation; //Background animation
SoundFile explosionBgm, spaceBgm, itemBgm, buttonBgm; //Sound effects and background music
Player player;
ArrayList < Enemy > enemy;
ArrayList < ExplosionGif > explosionGif;
ArrayList < Button > button;
ArrayList < Item > item;
int initEnemy,remainingLife,score,degreeOfDifficulty = 5,defaultDegreeOfDifficulty = 5;
float enemySize = 40, playerSize = 70;
String userName = null;
StringList userTopListName = new StringList();
IntList userTopListScore = new IntList();
boolean isNewGame = true, initImport = true, initName = true, nameIsConfirmed = false, shipIsChanged = false;
boolean personalizedSettings = false, exitIsConfirmed = false, isFirstTime = true;
String shipName, controllerMode = "Keyboard Mode";
UiBooster booster;
ListElement selectedElement;
FilledForm form;
ProgressDialog dialog;
Button exitButton;
void setup()
{
    size(700, 900);
    if (isFirstTime) {
        WaitingDialog waitingDialog;
        booster = new UiBooster();
        waitingDialog = booster.showWaitingDialog("Starting", "Starting program");  //GUI loading message
        delay(1500);
        waitingDialog.close();
        dialog = new UiBooster().showProgressDialog("Please wait", "Waiting", 0, 100); //GUI loading message
        for (int i = 0;i <= 10;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Starting program..."); //GUI loading message
            delay(10);
        }
        GUIInit(); //GUI initialization
        for (int i = 70;i <= 90;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Initializing game data..."); //GUI loading message
            delay(20);
        }
        GameInit(); //Game initialization
        for (int i = 90;i <= 99;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Almost done..."); //GUI loading message
            delay(20);
        }
        dialog.setProgress(100);
        dialog.setMessage("100%  Ready!"); //GUI loading message
        delay(1000);
        dialog.close();
    }
    else GameInit();
}
void draw()
{
    if (!button.get(0).action && !button.get(1).action && !button.get(2).action && !button.get(3).action && !button.get(4).action) GUIStartLoop(); //Main interface, animation and background music loop
    else if (button.get(0).action) //new game
        {
        CreateUser(); //User judgment and creation
        imageMode(CENTER);    
        frameRate(60);
        image(spaceAnimation, width / 2, height / 2, width, height); //Gif loop
        if (remainingLife > 0 && enemy.size()>0) { //The main engine of the game starts       
            player.Display();
            DisplayAndCheckItem();
            EnemyMove();
            PlayerMissileJudgment();
            EnemyMissileJudgment();
            CollideWithTheEnemy();
            CheckEnemyIsAlive();
            DisplayInfo();
            ExitGameButtonListener();
        } else {//The game ends and the result of the game is displayed
            spaceBgm.amp(0.2);
            CalculateAndDisplayTheFinalResult();
        }
    } else if (button.get(1).action) //Personalized Settings
        {
        mousePressed = false; //Mouse state reset
        button.get(1).action = false; //Button state reset
        personalizedSettings = true;
        shipIsChanged = true;
        booster = new UiBooster(); //Personalized Settings' form
    do {
            form = new UiBooster()
               .createForm("Personalized settings")
               .addSelection("Controller mode", "Keyboard Mode", "Mouse Mode") //Controller mode selection
               .addList("Choose your ship", 
                new ListElement("Ship 1 (Default ship)", "This is a standard spaceship.", dataPath("PlayerShip01.png")), 
                new ListElement("Ship 2", "This is a spaceship designed in red and blue.", dataPath("PlayerShip02.png")), 
                new ListElement("Ship 3", "This is a spaceship designed in blue and white.", dataPath("PlayerShip03.png")), 
                new ListElement("Ship 4", "This is a uniquely designed spaceship.\nIt has a cool shape design.", dataPath("PlayerShip04.png"))) //Spaceship selection
               .addSlider("Number of enemies (Default number of enemies is 50)", 50, 500, 50, 50, 9) //Enemy number selection
               .addSlider("Difficulty settings (Default degree of difficulty is 5)", 1, 10, degreeOfDifficulty, 3, 1) //Difficulty factor selection
               .andWindow()
               .setSize(500, 725) //Dialog size
               .setUndecorated()
               .setPosition(displayWidth / 2 - 500 / 2,displayHeight / 2 - 725 / 2) //Dialog position
               .save()
               .show();
            if (form.getByLabel("Choose your ship").getValue() == null) new UiBooster().showErrorDialog("You must choose a spaceship!", "ERROR"); //Show error message
        } while(form.getByLabel("Choose your ship").getValue() == null); //User ust choose a spaceship
        //Controller mode selection
        controllerMode = form.getByLabel("Controller mode").asString();
        //Spaceship selection
        String value = form.getByLabel("Choose your ship").asString(); //Get spaceship value from personalized Settings' form
        String listValue = "";
        int count = 0;
        boolean record = false;
        for (int i = 0; i < value.length(); i++) //Select the value within the first single quote
        {
            if (value.charAt(i) == char(39)) {
                count++;
                record = true;
            }
            if (count == 2) break;
            if (record && value.charAt(i + 1)!= char(39))
            {
                listValue +=value.charAt(i + 1);
            }
        }
        if (listValue.equals("Ship 1 (Default ship)")) shipName = "PlayerShip01";
        if (listValue.equals("Ship 2")) shipName = "PlayerShip02";
        if (listValue.equals("Ship 3")) shipName = "PlayerShip03";
        if (listValue.equals("Ship 4")) shipName = "PlayerShip04";
        player = new Player(playerSize, shipName,controllerMode); //Reinitialize the user's attributes
        initEnemy = form.getByLabel("Number of enemies (Default number of enemies is 50)").asInt(); //Get enemy number value from personalized Settings' form
        degreeOfDifficulty = form.getByLabel("Difficulty settings (Default degree of difficulty is 5)").asInt(); //Get difficulty factor value from personalized Settings' form
        enemy.clear(); //Clear enemy attributes that have been initialized
        for (int i = 0; i < initEnemy; i++) { //Reinitialize enemy attributes
            enemy.add(new Enemy(0 - i * 70, enemySize));
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
        }
        enemy.get(0).yMove = true; //Set the movement state of the first enemy to true
    } else if (button.get(2).action) //Leaderboard
        {
        mousePressed = false; //Mouse state reset
        button.get(2).action = false; //Button state reset
        CalculateResult();
        int displayNum;
        String textData = "Leaderboard - TOP 5\n\n";
        if (userTopListName.size()>= 5) displayNum = 5;
        else displayNum = userTopListName.size();
        for (int i = 0; i < displayNum; i++)
        {
            textData +=userTopListName.get(i);
            textData +=": ";
            textData +=userTopListScore.get(i);
            textData +="\n\n";            
        }
        booster = new UiBooster();
        booster.showInfoDialog(textData);
        
    } else if (button.get(3).action) //Help
        {
        mousePressed = false; //Mouse state reset
        button.get(3).action = false; //Button state reset
        booster = new UiBooster();
        booster.showPictures("Help",new String[] {
            dataPath("Help01.jpg")});
    } else if (button.get(4).action) //Exit
        {
        mousePressed = false; //Mouse state reset
        button.get(4).action = false; //Button state reset
        exit(); //Exit the game
    }
    if ((remainingLife == 0 || enemy.size() == 0) && mousePressed) //Game over and reinitialize the game
    {
        ResetGame();        
    }
}
void GUIInit()
{
    for (int i = 10;i <= 30;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Loading image and animation..."); //GUI loading message
        delay(20);
    }
    spaceAnimation = new Gif (this, "Space08.gif"); //Loading background animation
    spaceAnimation.loop();
    for (int i = 30;i <= 50;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Loading background music and special effects..."); //GUI loading message
        delay(20);
    }
    explosionBgm = new SoundFile(this, "Explosion.mp3"); //Loading sound effects and background music
    explosionBgm.amp(0.5);
    spaceBgm = new SoundFile(this, "Spacebgm.mp3");
    spaceBgm.amp(1);
    spaceBgm.loop();
    itemBgm = new SoundFile(this, "Item.mp3");
    itemBgm.amp(0.5);
    buttonBgm = new SoundFile(this, "ButtonSelect.mp3");
    buttonBgm.amp(1);
    for (int i = 50;i <= 70;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Initializing the game interface..."); //GUI loading message
        delay(20);
    }
    button = new ArrayList<Button>(); //Create button
    button.add(new Button(width / 2, height * 2.7 / 8, "New Game",30));
    button.add(new Button(width / 2, height * 3.45 / 8, "Personalized Settings",30));
    button.add(new Button(width / 2, height * 4.2 / 8, "Leaderboard",30));
    button.add(new Button(width / 2, height * 4.95 / 8, "Help",30));
    button.add(new Button(width / 2, height * 5.7 / 8, "Exit",30));
    exitButton = new Button(30,20,"Exit",16);
}
void GameInit()
{
    if (initImport) {
        ImportData(); //Import user data (only when starting the program at the very beginning)
        initImport = false;
    }
    remainingLife = 10; //Initial total number of lives
    score = 0; //Initial total score
    if (!personalizedSettings) //If the user does not personalize the game, the game uses the default settings to initialize
    {
        player = new Player(playerSize,controllerMode);
        initEnemy = 50; //Initial enemy number
    }
    else player = new Player(playerSize,shipName,controllerMode);
    enemy = new ArrayList<Enemy>(); //Initialize enemy
    item = new ArrayList<Item>(); //Initialize item
    explosionGif = new ArrayList < ExplosionGif > ();
    for (int i = 0; i < initEnemy; i++) {
        enemy.add(new Enemy(0 - i * 70, enemySize)); // Add enemy spaceship
        if (personalizedSettings)
        {
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
        }
    }
    enemy.get(0).yMove = true; //Set the movement state of the first enemy to true
}
void GUIStartLoop()
{
    spaceBgm.amp(1); //Background music volume setting
    imageMode(CENTER);  
    image(spaceAnimation, width / 2, height / 2, width, height); //Gif loop
    fill(255);
    stroke(255);
    textAlign(CENTER);
    textSize(60);
    textMode(MODEL);
    text("Space Invaders", width / 2, height * 1.5 / 8);
    textSize(20);
    text("Developed by Shuokai Ma", width / 2, height * 7 / 8);
    for (int i = 0; i < button.size(); i++) {
        button.get(i).createButton(); //Show buttons
    }
}
void DisplayAndCheckItem()
{
    if (random(0, 1)<0.003 - (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.0005) //Probability of the item depends on the degree of difficulty
    {
        item.add(new Item(random(0,1)));
    }
    for (int i = 0;i < item.size();i++)
    {
        item.get(i).Move(); //Items move
        if (item.get(i).y>height + item.get(i).itemSize) item.remove(i); //If the item is not in the game interface, remove the item
        if (item.size() == 0) break;
        if (item.get(i).x>player.x - playerSize / 2 && item.get(i).x<player.x + playerSize / 2 &&
            item.get(i).y>player.y - playerSize / 2 && item.get(i).y<player.y + playerSize / 2) //Determine whether the user gets the item
            {
            if (item.get(i).itemType == "LifeUp") //Item type 1 (add an extra life)
            {
                remainingLife++;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "MissileUp") //Item type 2 (Missile firing rate increased)
            {
                player.missileUpgrade +=50;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "UniqueSkill") //Item type 3 (Clear all enemies in the current screen)
            {
                itemBgm.play();
                for (int j = enemy.size() - 1;j >= 0;j--) //Scan all enemy spaceships and its missiles in the game interface, and then clear them
                {
                    if (enemy.get(j).y>0 && enemy.get(j).y<height + enemySize)
                    {
                        explosionBgm.play();
                        explosionGif.add(new ExplosionGif (enemy.get(j).x, enemy.get(j).y, this));                            
                        enemy.remove(j);
                        score +=100;
                    }
                }
            }
            item.remove(i); //After the user gets the item, the item will disappear
        }        
    } 
}
void EnemyMove()
{
    if (enemy.size() == 0) return; //If there are no more enemies, exit the function
    else enemy.get(0).yMove = true; //Else set the movement state of the first enemy to true
    for (int i = 0; i < enemy.size(); i++) 
        {
        //Prevent collision
        for (int j = 0; j < enemy.size() - 1; j++)
        {
            if (enemy.get(j).y - enemy.get(j + 1).y>50) {
                enemy.get(j + 1).yMove = true;
            } else
                enemy.get(j + 1).yMove = false;
        }
        //Move
        enemy.get(i).Move();
        if (enemy.get(i).y>height + enemySize) //If the enemy flies out of the game interface, remove the enemy
        {
            enemy.remove(i);
        }
    }
}
void CheckEnemyIsAlive()
{
    for (int i = 0;i < enemy.size();i++)
    {
        if (enemy.get(i).isDestroyed && enemy.get(i).missile.size() == 0) enemy.remove(i); //If the enemy is destroyed and its missile is no longer in the game interface, remove the enemy
    }
}
void PlayerMissileJudgment()
{
    for (int i = 0; i < player.missile.size(); i++)
        {
        for (int j = 0; j < enemy.size(); j++)
        {
            if (player.missile.get(i).x>enemy.get(j).x - enemySize / 2 && player.missile.get(i).x<enemy.get(j).x + enemySize / 2 &&
                player.missile.get(i).y>enemy.get(j).y - enemySize / 2 && player.missile.get(i).y<enemy.get(j).y + enemySize / 2) //Boundary judgment
            {
                explosionBgm.play(); //Play explosion sound
                explosionGif.add(new ExplosionGif (player.missile.get(i).x, player.missile.get(i).y, this)); //Add explosion animation  
                enemy.get(j).isDestroyed = true; //Mark the enemy has been destroyed
                enemy.get(j).y =- height; //Move the enemy's position outside the border
                player.missile.remove(i); //Remove the missile that the player hits the enemy
                score +=100; //Player score increase              
                break;
            }
        }
    }
    DisplayExplosion(); //Play explosion animation effect
}
void EnemyMissileJudgment()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        for (int j = 0; j < enemy.get(i).missile.size(); j++)
        {
            if (enemy.get(i).missile.get(j).x>player.x - playerSize / 2 && enemy.get(i).missile.get(j).x<player.x + playerSize / 2 &&
                enemy.get(i).missile.get(j).y>player.y - playerSize / 2 && enemy.get(i).missile.get(j).y<player.y + playerSize / 2) //Boundary judgment
            {
                explosionBgm.play(); //Play explosion sound
                explosionGif.add(new ExplosionGif (enemy.get(i).missile.get(j).x, enemy.get(i).missile.get(j).y, this)); //Add explosion animation  
                enemy.get(i).missile.remove(j); //Remove the missile that the enemy hits the player
                remainingLife--; //Player's lives lost
                score -=50; //Player score reduced
                if (score < 0) score = 0; //The minimum player score is 0
                break;
            }
        }
    }
    DisplayExplosion();
}
void CollideWithTheEnemy()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        if (((enemy.get(i).x + enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x + enemySize / 2<player.x + playerSize / 2) ||
           (enemy.get(i).x - enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x - enemySize / 2<player.x + playerSize / 2)) &&
           ((enemy.get(i).y + enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y + enemySize / 2<player.y + playerSize / 2) ||
           (enemy.get(i).y - enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y - enemySize / 2<player.y + playerSize / 2))) //Boundary judgment
        {
            explosionBgm.play(); //Play explosion sound
            explosionGif.add(new ExplosionGif ((enemy.get(i).x + player.x) / 2,(enemy.get(i).y + player.y) / 2, this)); //Add explosion animation
            enemy.get(i).isDestroyed = true; //Mark the enemy has been destroyed
            enemy.get(i).y =- height; //Move the enemy's position outside the border
            remainingLife--; //Player's lives lost
            score -=50; //Player score reduced
            if (score < 0) score = 0; //The minimum player score is 0
            if (enemy.size() == 0) break; //If there are no more enemies, exit the function
            enemy.get(0).yMove = true; //Set the movement state of the first enemy to true
            break;
        }
    }
    DisplayExplosion();
}
void DisplayInfo()
{
    //Display real-time data of the game
    fill(255);
    textSize(16);
    textAlign(LEFT);
    text("User:", width * 6 / 8, 20);
    text(userName, width * 7 / 8, 20);
    text("Life:", width * 6 / 8, 40);
    text(remainingLife, width * 7 / 8, 40);
    text("Score:", width * 6 / 8, 60);
    text(score, width * 7 / 8, 60);
    text("Enemy:", width * 6 / 8, 80);
    text(enemy.size(), width * 7 / 8, 80);
}
void CalculateAndDisplayTheFinalResult()
{
    //If it is a new game, it is determined whether the user already exists in the database, 
    //and if it exists and the user has broken his record, the user's highest score is updated. 
    //If the user does not exist in the database, add the user's name and current score.
    if (isNewGame) {
        isNewGame = false;
        if (!userTopListName.hasValue(userName)) 
        {
            userTopListName.append(userName);
            userTopListScore.append(score);
        } else
        {
            for (int i = 0; i < userTopListName.size(); i++) 
            {
                if (userName.equals(userTopListName.get(i)) == true)
                {
                    if (score > userTopListScore.get(i)) 
                        userTopListScore.set(i, score);
                    break;
                }
            }
        }
        CalculateResult(); //Update leaderboard
        SaveData(); //Save data and export data file
    }
    //Show the final game result
    fill(255);
    textAlign(CENTER);
    textSize(65);
    if (enemy.size()>0) text("GAME OVER!", width / 2, height * 1.5 / 8);
    else text("You Win!!!", width / 2, height * 1.5 / 8);
    textAlign(LEFT);
    textSize(30);
    text("Name:", width / 2 - 120, height * 2.5 / 8);
    text(userName, width / 2 + 30, height * 2.5 / 8);
    text("Score:", width / 2 - 120, height * 3 / 8);
    text(score, width / 2 + 30, height * 3 / 8);
    textAlign(CENTER);
    textSize(30);
    //Show the leaderboard
    text("Leaderboard - TOP 3", width / 2, height * 4.25 / 8);
    int displayNum;
    if (userTopListName.size()>= 3) displayNum = 3;
    else displayNum = userTopListName.size();
    for (int i = 0; i < displayNum; i++)
        {
        textSize(25);
        text(userTopListName.get(i), width / 2 - 100, height * (4.25 + (i + 1) * 0.5) / 8);
        text(userTopListScore.get(i), width / 2 + 60, height * (4.25 + (i + 1) * 0.5) / 8);
    }
    textSize(20);
    text("Click the left mouse button to restart the game", width / 2, height * 7 / 8);
}
void DisplayExplosion()
{
    for (int i = 0; i < explosionGif.size(); i++)
        {
        explosionGif.get(i).Display(); //Play explosion effect
        if (!explosionGif.get(i).status) //If the effect is over, remove the effect
        {
            explosionGif.remove(i);
        }
    }
}
void ResetGame()
{
    //Reset lists,variables... and prepare for the next run
    enemy.clear();
    item.clear();
    //spaceBgm.stop();
    isNewGame = true;
    button.get(0).action = false;
    button.get(1).action = false;
    button.get(2).action = false;
    button.get(3).action = false;
    button.get(4).action = false;
    isFirstTime = false;
    mousePressed = false;
    setup();
}
void ImportData()
{
    //Read the json file and import it into the program
    JSONArray userData = loadJSONArray("data/userData.json");
    for (int i = 0; i < userData.size(); i++)
        {
        userTopListName.append(userData.getJSONObject(i).getString("name"));
        userTopListScore.append(userData.getJSONObject(i).getInt("score"));
    }
}
void SaveData()
{
    //Save the data file and output it as a json file
    JSONArray userNewData = new JSONArray();
    for (int i = 0; i < userTopListName.size(); i++)
        {
        JSONObject userDataTemp = new JSONObject();
        userDataTemp.setString("name", userTopListName.get(i));
        userDataTemp.setFloat("score", userTopListScore.get(i));
        userNewData.setJSONObject(i, userDataTemp);
    }
    saveJSONArray(userNewData, "data/userData.json");
}
void CreateUser()
{
    while((userTopListName.hasValue(userName) || userName == null) && initName && !nameIsConfirmed) //Determine whether the user is legal (whether it exists in the database, is it a blank name)
        {
        mousePressed = false;
        userName = new UiBooster().showTextInputDialog("Please enter your name:");
        if (userName == null || userName.equals("")) new UiBooster().showErrorDialog("The name is not allowed to be empty!", "ERROR");
        if (userTopListName.hasValue(userName) && !userName.equals("")) //If the current user name already exists in the database, it will prompt a message
        {
            booster = new UiBooster();
            booster.showConfirmDialog(
                "Detected the same name! If you are the owner of this name, please click Yes and log in to\nthe game with this name, otherwise please click No and enter your new name!", 
                "Info - Detected the same name!", 
                new Runnable() {
                public void run() {
                    nameIsConfirmed = true;
                }
            }
            , 
            new Runnable() {
                public void run() {
                    nameIsConfirmed = false;
                }
            }
           );
        }
    }
    initName = false;
}
void CalculateResult()
{
    //Sort users' scores from high to low (bubble sort)
    int tempScore;
    String tempName;
    for (int i = 0; i < userTopListName.size() - 1; i++) 
        {
        for (int j = 0; j < userTopListName.size() - 1 - i; j++) 
            {
            if (userTopListScore.get(j) < userTopListScore.get(j + 1)) 
                {
                tempScore = userTopListScore.get(j);
                userTopListScore.set(j, userTopListScore.get(j + 1)); 
                userTopListScore.set(j + 1, tempScore); 
                tempName = userTopListName.get(j);
                userTopListName.set(j, userTopListName.get(j + 1));
                userTopListName.set(j + 1, tempName);
            }
        }
    }
}
void ExitGameButtonListener()
{
    exitButton.createButton(); //Create an exit button
    if (exitButton.action) //Check whether the button is triggered
    {
        mousePressed = false;
        exitButton.action = false;
        booster = new UiBooster();//Second reminder
        booster.showConfirmDialog(
            "Are you sure to exit the game? Please note that your game data will not be saved!",
            "Exit Game",
            new Runnable() {
            public void run() {
                exitIsConfirmed = true;
            }
        } ,
        new Runnable() {
            public void run() {
                exitIsConfirmed = false;
            }
        }
       );
    }
    if (exitIsConfirmed) //If the button is triggered, exit the game
    {
        ResetGame();
        exitIsConfirmed = false;
    }
}