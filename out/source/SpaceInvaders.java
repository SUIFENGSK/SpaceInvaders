import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import uibooster.*; 
import uibooster.components.*; 
import uibooster.model.*; 
import uibooster.model.formelements.*; 
import uibooster.utils.*; 
import gifAnimation.*; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SpaceInvaders extends PApplet {








private Gif spaceAnimation; //Background animation
private SoundFile explosionBgm, spaceBgm, itemBgm, buttonBgm; //Sound effects and background music
private Player player;
private ArrayList < Enemy > enemy;
private ArrayList < ExplosionGif > explosionGif;
private ArrayList < Button > button;
private ArrayList < Item > item;
private int initEnemy,remainingLife,score,degreeOfDifficulty = 5,defaultDegreeOfDifficulty = 5;
private float enemySize = 40, playerSize = 70;
private String userName = null;
private StringList userTopListName = new StringList();
private IntList userTopListScore = new IntList();
private boolean isNewGame = true, initImport = true, initName = true, nameIsConfirmed = false, shipIsChanged = false;
private boolean personalizedSettings = false, exitIsConfirmed = false, isFirstTime = true;
private String shipName, controllerMode = "Keyboard Mode";
private UiBooster booster;
private ListElement selectedElement;
private FilledForm form;
private ProgressDialog dialog;
private Button exitButton;
public void setup()
{
    
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
public void draw()
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
            spaceBgm.amp(0.2f);
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
            if (value.charAt(i) == PApplet.parseChar(39)) {
                count++;
                record = true;
            }
            if (count == 2) break;
            if (record && value.charAt(i + 1)!= PApplet.parseChar(39))
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
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
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
private void GUIInit()
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
    explosionBgm.amp(0.5f);
    spaceBgm = new SoundFile(this, "Spacebgm.mp3");
    spaceBgm.amp(1);
    spaceBgm.loop();
    itemBgm = new SoundFile(this, "Item.mp3");
    itemBgm.amp(0.5f);
    buttonBgm = new SoundFile(this, "ButtonSelect.mp3");
    buttonBgm.amp(1);
    for (int i = 50;i <= 70;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Initializing the game interface..."); //GUI loading message
        delay(20);
    }
    button = new ArrayList<Button>(); //Create button
    button.add(new Button(width / 2, height * 2.7f / 8, "New Game",30));
    button.add(new Button(width / 2, height * 3.45f / 8, "Personalized Settings",30));
    button.add(new Button(width / 2, height * 4.2f / 8, "Leaderboard",30));
    button.add(new Button(width / 2, height * 4.95f / 8, "Help",30));
    button.add(new Button(width / 2, height * 5.7f / 8, "Exit",30));
    exitButton = new Button(30,20,"Exit",16);
}
private void GameInit()
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
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
        }
    }
    enemy.get(0).yMove = true; //Set the movement state of the first enemy to true
}
private void GUIStartLoop()
{
    spaceBgm.amp(1); //Background music volume setting
    imageMode(CENTER);  
    image(spaceAnimation, width / 2, height / 2, width, height); //Gif loop
    fill(255);
    stroke(255);
    textAlign(CENTER);
    textSize(60);
    textMode(MODEL);
    text("Space Invaders", width / 2, height * 1.5f / 8);
    textSize(20);
    text("Developed by Shuokai Ma", width / 2, height * 7 / 8);
    for (int i = 0; i < button.size(); i++) {
        button.get(i).CreateButton(); //Show buttons
    }
}
private void DisplayAndCheckItem()
{
    if (random(0, 1)<0.003f - (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.0005f) //Probability of the item depends on the degree of difficulty
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
private void EnemyMove()
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
private void CheckEnemyIsAlive()
{
    for (int i = 0;i < enemy.size();i++)
    {
        if (enemy.get(i).isDestroyed && enemy.get(i).missile.size() == 0) enemy.remove(i); //If the enemy is destroyed and its missile is no longer in the game interface, remove the enemy
    }
}
private void PlayerMissileJudgment()
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
private void EnemyMissileJudgment()
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
private void CollideWithTheEnemy()
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
private void DisplayInfo()
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
private void CalculateAndDisplayTheFinalResult()
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
    if (enemy.size()>0) text("GAME OVER!", width / 2, height * 1.5f / 8);
    else text("You Win!!!", width / 2, height * 1.5f / 8);
    textAlign(LEFT);
    textSize(30);
    text("Name:", width / 2 - 120, height * 2.5f / 8);
    text(userName, width / 2 + 30, height * 2.5f / 8);
    text("Score:", width / 2 - 120, height * 3 / 8);
    text(score, width / 2 + 30, height * 3 / 8);
    textAlign(CENTER);
    textSize(30);
    //Show the leaderboard
    text("Leaderboard - TOP 3", width / 2, height * 4.25f / 8);
    int displayNum;
    if (userTopListName.size()>= 3) displayNum = 3;
    else displayNum = userTopListName.size();
    for (int i = 0; i < displayNum; i++)
        {
        textSize(25);
        text(userTopListName.get(i), width / 2 - 100, height * (4.25f + (i + 1) * 0.5f) / 8);
        text(userTopListScore.get(i), width / 2 + 60, height * (4.25f + (i + 1) * 0.5f) / 8);
    }
    textSize(20);
    text("Click the left mouse button to restart the game", width / 2, height * 7 / 8);
}
private void DisplayExplosion()
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
private void ResetGame()
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
private void ImportData()
{
    //Read the json file and import it into the program
    JSONArray userData = loadJSONArray("data/userData.json");
    for (int i = 0; i < userData.size(); i++)
        {
        userTopListName.append(userData.getJSONObject(i).getString("name"));
        userTopListScore.append(userData.getJSONObject(i).getInt("score"));
    }
}
private void SaveData()
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
private void CreateUser()
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
private void CalculateResult()
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
private void ExitGameButtonListener()
{
    exitButton.CreateButton(); //Create an exit button
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
class Button 
{
    public float x, y;
    private String text;
    public float buttonWidth = 200, buttonHeight = 80; //Set the size of the button
    private float R = 225, G = 225, B = 225; //Set the color of the button
    public boolean action = false;
    private boolean buttonBgmControl = true;
    private float textSize;
    public Button(float x, float y, String text, float textSize) 
    {
        this.x = x;
        this.y = y;
        this.text = text;
        this.textSize = textSize;
    }
    public void CreateButton()
    {
        //Create and display button
        pushMatrix();
        stroke(0);
        Render(); //Render button
        rectMode(CENTER);
        fill(R, G, B);
        //rect(x, y, buttonWidth, buttonHeight);
        textSize(textSize);
        textAlign(CENTER, CENTER);
        text(text, x, y);
        popMatrix();
        //Check whether the button is triggered
        CheckButton();
    }
    private void Render() 
    {
        //If the mouse position coincides with the button position, re-render the button (change the color of the button)
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
            R = 138;
            G = 217;
            B = 78;
            if (buttonBgmControl) 
            {
                buttonBgm.play();
                buttonBgmControl = false;
            }
        } else {
            R = 225;
            G = 225;
            B = 225;
            buttonBgmControl = true;
        }
    }
    private void CheckButton() 
    {
        //Check whether the button is triggered. Return true if triggered
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) 
        {
            if (mousePressed && action == false)  action = true;
            else  action = false;
        }
    }
}
class Enemy
{
    private float enemySize;
    public float x, y;
    private float xSpeed = 3, ySpeed = 3; //Initialization speed of the enemy spaceship
    private int time = 0;
    private int lastTime = 0;
    private boolean xyDirection;
    public boolean yMove = false, isDestroyed = false;
    public ArrayList<Missile> missile = new ArrayList<Missile>();
    private Pic enemyShipImg = new Pic("EnemyShip"); //Read and import enemy spaceship's picture
    public Enemy(float y, float enemySize)
    {
        x = random(enemySize / 2 + 10, width - enemySize / 2 - 10); //Initialize the x-coordinate of the item randomly
        this.y = y; //Import the y-coordinate of the enemy spaceship
        this.enemySize = enemySize; //Import the size of the enemy spaceship
    }
    public void Move()
    {
        if (!isDestroyed) //If the enemy spaceship is not destroyed, the enemy spaceship can move
        {
            time = millis() - lastTime;
            imageMode(CENTER);
            enemyShipImg.Display(x,y,enemySize,enemySize); //Display enemy spaceship's picture
            if (time > 500) {//The enemy spaceship changes direction every 500ms
                lastTime = millis();
                //change y-direction. The probability of the enemy’s y-direction change depends on the degree of difficulty
                if (random(0, 1)<0.5f + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.06f) xyDirection = false; 
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
    private void MissileAdd()
    {
        if (!isDestroyed && random(0, 1)<0.01f + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.001f) //The firing frequency of enemy missiles depends on the difficulty of the game
        {
            missile.add(new Missile(x, y, "ENEMY")); //Add enemy's missile
        }        
    }
    private void MissileLaunch()
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
class ExplosionGif
{
    private Gif explosion;
    private float x, y;
    public boolean status = true;
    public ExplosionGif (float x, float y, PApplet explosionGif)
    {
        explosion = new Gif (explosionGif, "Explosion.gif"); //Read and import the gif-image of the explosion
        explosion.play(); //Set the gif-image of the explosion's status to play
        this.x = x; //Get explosion coordinates
        this.y = y;
    }
    public void Display()
    {
        if (explosion.currentFrame()<25)
        {
            image(explosion, x, y, 120, 120);
        } else //If the gif-image of the current explosion has been played once, stop playing
        {
            explosion.stop();
            status = false;
        }
    }
}
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
        if (randomNum < 0.45f) //There is a 45 percent chance of getting an extra life
        {
            itemImg = new Pic("LifeUp");
            itemType = "LifeUp";
        }
        if (randomNum >= 0.45f && randomNum < 0.9f) //There is a 45 percent chance of increasing missile firing rate
        {
            itemImg = new Pic("MissileUp");
            itemType = "MissileUp";
        }
        
        if (randomNum >=0.9f) //There is a 10 percent chance of clearing all enemies in the current screen
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
class Pic {
    private PImage img;
    private int k;
    public Pic(String filename) 
    {
        img = loadImage(filename + ".png"); //Read and import image data
    }
    public Pic(String filename, int temp) 
    {
        k = temp;
        img = loadImage(filename + k + ".png"); //Read and import image data
    }
    public void Display(float x, float y, float pWidth, float pHeight)
    {
        imageMode(CENTER);
        image(img, x, y, pWidth, pHeight); //Display image
    }
}
class Player
{
    public float x = width / 2; //Player's initial coordinates
    public float y = height * 7 / 8;
    private float moveSpeed = 10; //Player movement speed
    private float playerSize;
    private int time = 0;
    private int lastTime = 0;
    public ArrayList<Missile> missile = new ArrayList<Missile>();
    private Pic playerShipImg; //Picture of the player's spaceship
    public int missileUpgrade = 0; //The missile status of the player's spaceship
    private String controllerMode;
    public Player(float playerSize, String shipName, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic(shipName);
    }
    public Player(float playerSize, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic("PlayerShip01");
    }
    public void Display()
    {
        imageMode(CENTER);
        playerShipImg.Display(x, y, playerSize, playerSize); //Display player's spaceship
        if(controllerMode.equals("Keyboard Mode")) KeyboardMove(); //Keyboard mode
        if(controllerMode.equals("Mouse Mode")) MouseMove(); //Mouse mode
        MissileLaunch(); //The player fires a missile
    }
    private void KeyboardMove()
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
    private void MouseMove()
    {
        x=mouseX;
        y=mouseY;
        //Boundary judgment
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    private void MissileLaunch()
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
  public void settings() {  size(700, 900); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SpaceInvaders" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
