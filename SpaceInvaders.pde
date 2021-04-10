import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.utils.*;
import gifAnimation.*;
import processing.sound.*;
Gif spaceAnimation;
SoundFile explosionBgm, spaceBgm, itemBgm, buttonBgm;
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
        waitingDialog = booster.showWaitingDialog("Starting", "Starting program");
        //waitingDialog.setLargeMessage("Loading image...\nLoading animation...\nLoading background music...\nInitializing the game interface...");
        delay(1500);
        waitingDialog.close();
        dialog = new UiBooster().showProgressDialog("Please wait", "Waiting", 0, 100);
        for (int i = 0;i <= 10;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Starting program...");
            delay(10);
        }
        GUIInit();
        for (int i = 70;i <= 90;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Initializing game data...");
            delay(20);
        }
        GameInit();
        for (int i = 90;i <= 99;i++) 
        {
            dialog.setProgress(i);
            dialog.setMessage(i + "%  Almost done...");
            delay(20);
        }
        dialog.setProgress(100);
        dialog.setMessage("100%  Ready!");
        delay(1000);
        dialog.close();
    }
    else GameInit();
}
void draw()
{
    if (!button.get(0).action && !button.get(1).action && !button.get(2).action && !button.get(3).action && !button.get(4).action) GUIStartLoop();
    else if (button.get(0).action) //new game
        {
        //button.get(1).action = false;
        CreateUser();
        imageMode(CENTER);    
        frameRate(60);
        image(spaceAnimation, width / 2, height / 2, width, height); 
        if (remainingLife > 0 && enemy.size()>0) {        
            player.Display();
            DisplayAndCheckItem();
            EnemyMove();
            PlayerMissileJudgment();
            EnemyMissileJudgment();
            CollideWithTheEnemy();
            CheckEnemyIsAlive();
            DisplayInfo();
            ExitGameButtonListener();
        } else {
            spaceBgm.amp(0.2);
            CalculateAndDisplayTheFinalResult();
        }
    } else if (button.get(1).action) //Personalized Settings
        {
        mousePressed = false;
        button.get(1).action = false;
        personalizedSettings = true;
        shipIsChanged = true;
        booster = new UiBooster();
    do {
            form = new UiBooster()
               .createForm("Personalized settings")
               .addSelection("Controller mode", "Keyboard Mode", "Mouse Mode")
               .addList("Choose your ship", 
                new ListElement("Ship 1 (Default ship)", "This is a standard spaceship.", dataPath("PlayerShip01.png")), 
                new ListElement("Ship 2", "This is a spaceship designed in red and blue.", dataPath("PlayerShip02.png")), 
                new ListElement("Ship 3", "This is a spaceship designed in blue and white.", dataPath("PlayerShip03.png")), 
                new ListElement("Ship 4", "This is a uniquely designed spaceship.\nIt has a cool shape design.", dataPath("PlayerShip04.png")))
               .addSlider("Number of enemies (Default number of enemies is 50)", 50, 500, 50, 50, 9)
               .addSlider("Difficulty settings (Default degree of difficulty is 5)", 1, 10, degreeOfDifficulty, 3, 1)
               .andWindow()
               .setSize(500, 725)
               .setUndecorated()
               .setPosition(displayWidth / 2 - 500 / 2,displayHeight / 2 - 725 / 2)
               .save()
               .show();
            if (form.getByLabel("Choose your ship").getValue() == null) new UiBooster().showErrorDialog("You must choose a spaceship!", "ERROR");
        } while(form.getByLabel("Choose your ship").getValue() == null);
        controllerMode = form.getByLabel("Controller mode").asString();
        String value = form.getByLabel("Choose your ship").asString();
        String listValue = "";
        int count = 0;
        boolean record = false;
        //println(value);
        for (int i = 0; i < value.length(); i++)
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
        //println(listValue);
        if (listValue.equals("Ship 1 (Default ship)")) shipName = "PlayerShip01";
        if (listValue.equals("Ship 2")) shipName = "PlayerShip02";
        if (listValue.equals("Ship 3")) shipName = "PlayerShip03";
        if (listValue.equals("Ship 4")) shipName = "PlayerShip04";
        player = new Player(playerSize, shipName,controllerMode);
        initEnemy = form.getByLabel("Number of enemies (Default number of enemies is 50)").asInt();
        degreeOfDifficulty = form.getByLabel("Difficulty settings (Default degree of difficulty is 5)").asInt();
        enemy.clear();
        for (int i = 0; i < initEnemy; i++) {
            enemy.add(new Enemy(0 - i * 70, enemySize));
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
        }
        enemy.get(0).yMove = true;
        //println(degreeOfDifficulty);
    } else if (button.get(2).action) //Leaderboard
        {
        mousePressed = false;
        button.get(2).action = false;
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
        mousePressed = false;
        button.get(3).action = false;
        booster = new UiBooster();
        booster.showPictures("Help",new String[] {
            dataPath("Help01.jpg")});
    } else if (button.get(4).action) //Exit
        {
        mousePressed = false;
        button.get(4).action = false;
        exit();
    }
    if ((remainingLife == 0 || enemy.size() == 0) && mousePressed) //init Game
    {
        ResetGame();        
    }
}
void GUIInit()
{
    for (int i = 10;i <= 30;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Loading image and animation...");
        delay(20);
    }
    spaceAnimation = new Gif (this, "Space08.gif");
    spaceAnimation.loop();
    for (int i = 30;i <= 50;i++) 
    {
        dialog.setProgress(i);
        dialog.setMessage(i + "%  Loading background music and special effects...");
        delay(20);
    }
    explosionBgm = new SoundFile(this, "Explosion.mp3");
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
        dialog.setMessage(i + "%  Initializing the game interface...");
        delay(20);
    }
    button = new ArrayList<Button>();
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
        ImportData();
        initImport = false;
    }
    remainingLife = 10;
    score = 0;
    if (!personalizedSettings) 
    {
        player = new Player(playerSize,controllerMode);
        initEnemy = 50;
    }
    else player = new Player(playerSize,shipName,controllerMode);
    enemy = new ArrayList<Enemy>();
    item = new ArrayList<Item>();
    explosionGif = new ArrayList < ExplosionGif > ();
    for (int i = 0; i < initEnemy; i++) {
        enemy.add(new Enemy(0 - i * 70, enemySize));
        if (personalizedSettings)
        {
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2;
        }
    }
    enemy.get(0).yMove = true;
}
void GUIStartLoop()
{
    spaceBgm.amp(1);
    imageMode(CENTER);  
    image(spaceAnimation, width / 2, height / 2, width, height);
    fill(255);
    stroke(255);
    textAlign(CENTER);
    textSize(60);
    textMode(MODEL);
    text("Space Invaders", width / 2, height * 1.5 / 8);
    textSize(20);
    text("Developed by Shuokai", width / 2, height * 7 / 8);
    for (int i = 0; i < button.size(); i++) {
        button.get(i).createButton();
    }
}
void DisplayAndCheckItem()
{
    //println(player.missileUpgrade);
    if (random(0, 1)<0.003 - (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.0005) 
    {
        item.add(new Item(random(0,1)));
    }
    for (int i = 0;i < item.size();i++)
    {
        item.get(i).Move();
        if (item.get(i).y>height + item.get(i).itemSize) item.remove(i);
        if (item.size() == 0) break;
        if (item.get(i).x>player.x - playerSize / 2 && item.get(i).x<player.x + playerSize / 2 &&
            item.get(i).y>player.y - playerSize / 2 && item.get(i).y<player.y + playerSize / 2)
            {
            if (item.get(i).itemType == "LifeUp") 
            {
                remainingLife++;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "MissileUp")
            {
                player.missileUpgrade +=50;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "UniqueSkill")
            {
                itemBgm.play();
                for (int j = enemy.size() - 1;j >= 0;j--)
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
            item.remove(i);
        }        
    } 
}
void EnemyMove()
{
    if (enemy.size() == 0) return;
    else enemy.get(0).yMove = true;
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
        if (enemy.get(i).y>height + enemySize)
        {
            enemy.remove(i);
        }
        //println(i, enemy.get(0).yMove);
    }
}
void CheckEnemyIsAlive()
{
    for (int i = 0;i < enemy.size();i++)
    {
        if (enemy.get(i).isDestroyed && enemy.get(i).missile.size() == 0) enemy.remove(i);
    }
}
void PlayerMissileJudgment()
{
    for (int i = 0; i < player.missile.size(); i++)
        {
        for (int j = 0; j < enemy.size(); j++)
        {
            if (player.missile.get(i).x>enemy.get(j).x - enemySize / 2 && player.missile.get(i).x<enemy.get(j).x + enemySize / 2 &&
                player.missile.get(i).y>enemy.get(j).y - enemySize / 2 && player.missile.get(i).y<enemy.get(j).y + enemySize / 2)
            {
                explosionBgm.play();
                explosionGif.add(new ExplosionGif (player.missile.get(i).x, player.missile.get(i).y, this));   
                enemy.get(j).isDestroyed = true;
                enemy.get(j).y =- height;
                player.missile.remove(i);
                score +=100;
                //if (enemy.size() == 0) break;
                //enemy.get(0).yMove = true;                
                break;
            }
        }
    }
    DisplayExplosion();
}
void EnemyMissileJudgment()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        for (int j = 0; j < enemy.get(i).missile.size(); j++)
        {
            if (enemy.get(i).missile.get(j).x>player.x - playerSize / 2 && enemy.get(i).missile.get(j).x<player.x + playerSize / 2 &&
                enemy.get(i).missile.get(j).y>player.y - playerSize / 2 && enemy.get(i).missile.get(j).y<player.y + playerSize / 2)
            {
                explosionBgm.play();
                explosionGif.add(new ExplosionGif (enemy.get(i).missile.get(j).x, enemy.get(i).missile.get(j).y, this));
                enemy.get(i).missile.remove(j);
                remainingLife--;
                score -=50;
                if (score < 0) score = 0;
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
           (enemy.get(i).y - enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y - enemySize / 2<player.y + playerSize / 2)))
        {
            explosionBgm.play();
            explosionGif.add(new ExplosionGif ((enemy.get(i).x + player.x) / 2,(enemy.get(i).y + player.y) / 2, this));
            enemy.get(i).isDestroyed = true;
            enemy.get(i).y =- height;
            remainingLife--;
            score -=50;
            if (score < 0) score = 0;
            if (enemy.size() == 0) break;
            enemy.get(0).yMove = true;
            break;
        }
    }
    DisplayExplosion();
}
void DisplayInfo()
{
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
        CalculateResult();
        SaveData();
    }
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
    text("Click the mouse to restart the game", width / 2, height * 7 / 8);
}
void DisplayExplosion()
{
    for (int i = 0; i < explosionGif.size(); i++)
        {
        explosionGif.get(i).Display();
        if (!explosionGif.get(i).status)
        {
            explosionGif.remove(i);
        }
    }
}
void ResetGame()
{
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
    JSONArray userData = loadJSONArray("data/userData.json");
    for (int i = 0; i < userData.size(); i++)
        {
        userTopListName.append(userData.getJSONObject(i).getString("name"));
        userTopListScore.append(userData.getJSONObject(i).getInt("score"));
    }
}
void SaveData()
{
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
    while((userTopListName.hasValue(userName) || userName == null) && initName && !nameIsConfirmed)
        {
        mousePressed = false;
        userName = new UiBooster().showTextInputDialog("Please enter your name:");
        if (userName == null || userName.equals("")) new UiBooster().showErrorDialog("The name is not allowed to be empty!", "ERROR");
        if (userTopListName.hasValue(userName) && !userName.equals(""))
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
    exitButton.createButton();
    if (exitButton.action)
    {
        mousePressed = false;
        exitButton.action = false;
        booster = new UiBooster();
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
    if (exitIsConfirmed) 
    {
        ResetGame();
        exitIsConfirmed = false;
    }
}