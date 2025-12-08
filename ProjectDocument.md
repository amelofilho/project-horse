# Black Rabbit Rhapsody #

## Summary ##

Turn-based autobattler 

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1jB2_lGxjSw8QCz2dgsFHjkJ77vtSrayT5uPSMNy5jAg/edit?usp=sharing)  

## Gameplay Explanation ##

In battle, there is a skill selection UI that can be broken down into columns with each representing one attack slot. Players can pick one of three available skills for an attack slot, or click on the button below (either portrait or defend button) to queue up an attack skill instead. Skills are then processed in order from fastest to slowest (based on speed number below the set of skills), left-to-right and pitted against the enemy's skills. 

Player skills and enemies skills then clash against each other, rolling for highest number to see who gets to attack. Players can do a QTE activated by clicking in order to gain more clash value. After clashing, whoever won the clash (winning enough times to break all the enemy skill's coins) gets to attack with the remaining coins on their skill. 

Once all skills are clashed or processed, the next turn begins. This goes on until one side is defeated.

**Strategy**
Pick big numbers to go up against enemy numbers. Defend when you feel like losing is inevitable.

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

Agentic Tools were used during the creation of an early draft of the UI code and for minor debugging.

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```
## Alexander Landess
  ### Game Logic
    asdf
  ### Gameplay Testing
    asdf
  ### Other Contributions
    asdf

## Kynan Lewis
  ### Level/World Designer
    asdf
  ### Game Feel
    asdf
  ### Other Contributions
    asdf

# Xiaofeng Lin
  ### Systems and Tools Engineer
    asdf
  ### Build/Release Management
    asdf
  ### Other Contributions
    asdf

# Danielle Chang
  ### Animation/Visuals
    asdf
  ### Narrative Design
    asdf
  ### Other Contributions
    asdf

# Adriano Melo Filho
  ### UI/Input
    asdf
  ### Audio
    asdf
  ### Other Contributions
    asdf

# Justin Pak
### Producer
High Level Design - The game's original high level design consists of separate classes being handled by a global state machine. The intent was to break down the subsystems so that they are compartmentalized and can be worked on independently of each other.
  
<img src="DocImages/high-level-1.jpg" width="500"/>
  
Project Trello: https://trello.com/b/zCzT0oPH/project-horse-ecs-179
### Visual Cohesion/Style Guide
asdf
### Other Contributions
#### Test
asdf
    
For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##
