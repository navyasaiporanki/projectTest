import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import { bool } from 'prop-types';
//import sample from './image.jpg';

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel = {channel}/>, root);
}


class Starter extends React.Component {
  constructor(props) {
	super(props);
	this.channel = props.channel;
    this.state = {
		playerOneCards: [[" ", " "],[" ", " "],[" ", " "],[" ", " "],[" ", " "],[" ", " "]],
		playerTwoCards: [[" ", " "],[" ", " "],[" ", " "],[" ", " "],[" ", " "],[" ", " "]],
		asidePile: [["empty", "empty"]],
		remainingPile: [" ", " "],
		playerChance: 1,
		lastChance: false,
		scores: [["-","-"], ["-","-"], ["-","-"]],
		totalScore: ["-", "-"],
		lastChanceLocal: false,
		currentRound: 1
	};
	this.channel
        .join()
        .receive("ok", this.got_view.bind(this))
		.receive("error", resp => { console.log("Unable to join", resp); });
  }

  got_view(view) {
	 
    console.log("new view", view);
    this.setState(view.game);
   }

  handleDragStart(e) {
	e.dataTransfer.setData("text/plain", e.target.id)
  }

  handleDropForPlayerOne(e){
	if(e.preventDefault) { e.preventDefault(); }
	if(e.stopPropagation) { e.stopPropagation(); }
	var sourceId = e.dataTransfer.getData("text");
	var destId = e.target.parentElement.attributes.id.nodeValue;
	var playerNum = parseInt(destId.charAt(1))
	var playerCardNum = parseInt(destId.charAt(3))
	if((playerCardNum === 2 || playerCardNum === 5) && this.state.playerChance === playerNum){
		this.handleDrops(sourceId, destId, playerNum, playerCardNum)
	}else if(this.state.playerOneCards[1][0] === this.state.playerOneCards[4][0] && this.state.playerChance === playerNum){
		this.handleDrops(sourceId, destId, playerNum, playerCardNum)
	}
  }
  
  handleDropForPlayerTwo(e){
	if(e.preventDefault) { e.preventDefault(); }
	if(e.stopPropagation) { e.stopPropagation(); }
	var sourceId = e.dataTransfer.getData("text");
	var destId = e.target.parentElement.attributes.id.nodeValue;
	var playerNum = parseInt(destId.charAt(1))
	var playerCardNum = parseInt(destId.charAt(3))
	if((playerCardNum === 2 || playerCardNum === 5) && this.state.playerChance === playerNum){
		this.handleDrops(sourceId, destId, playerNum, playerCardNum)
	}else if(this.state.playerTwoCards[1][0] === this.state.playerTwoCards[4][0] && this.state.playerChance === playerNum){
		this.handleDrops(sourceId, destId, playerNum, playerCardNum)
	}
  }

  handleDrops(sourceId, destId, playerNum, playerCardNum){
	if(sourceId === "remainingPile" && destId != "asidePile") {
		this.channel.push("dropFromRemaining", { player: playerNum, change: playerCardNum})
		.receive("ok", this.got_view.bind(this));
	}else if(sourceId === "asidePile" && destId != "asidePile" && this.state.asidePile[this.state.asidePile.length - 1][0] != "empty"){
		this.channel.push("dropFromAside", { player: playerNum, change: playerCardNum})
		.receive("ok", this.got_view.bind(this));
	} 
  }

  handleDropToAsidePile(e){
	if(e.preventDefault) { e.preventDefault(); }
	if(e.stopPropagation) { e.stopPropagation(); }
	this.channel.push("dropToAside", { player: 1}).receive("ok", this.got_view.bind(this));
  }

  checkIfSpacesExists(inputArray){
	var rtVal = true; 
	inputArray.forEach(function(element){
		  if(element[0] === " "){
			rtVal = false;
		  }
	});
	return rtVal;
  }

  componentDidUpdate(){
	this.checkIfPlayerWonFirst();
  }

  checkIfPlayerWonFirst(){


	if(this.state.lastChanceLocal){
		this.state.lastChanceLocal = false;
		this.assignScores();
		return;
	}
	if(this.state.playerOneCards[0][0] === this.state.playerOneCards[3][0] 
		&& this.state.playerOneCards[1][0] === this.state.playerOneCards[4][0] 
		&& this.state.playerOneCards[2][0] === this.state.playerOneCards[5][0] 
		&& this.checkIfSpacesExists(this.state.playerOneCards) && this.state.lastChance === false){
		alert("Lets Provide Player2 last chance");	
		
		//this.channel.push("setLastChance", { player: 1}).receive("ok", this.got_view.bind(this));
		this.state.lastChanceLocal =  true;
		console.log("player  won" +  this.state.lastChanceLocal);
	}else if(this.state.playerTwoCards[0][0] === this.state.playerTwoCards[3][0] 
		&& this.state.playerTwoCards[1][0] === this.state.playerTwoCards[4][0] 
		&& this.state.playerTwoCards[2][0] === this.state.playerTwoCards[5][0]  
		&& this.checkIfSpacesExists(this.state.playerTwoCards) && this.state.lastChance === false) {
		alert("Lets Provide Player1 last chance");	
		//this.channel.push("setLastChance", { player: 1}).receive("ok", this.got_view.bind(this));
		this.state.lastChanceLocal =  true;
		console.log("player  won" +  this.state.lastChanceLocal);
	}else if(this.state.lastChance === true){
		this.assignScores();
	}
  }

  assignScores(){
	  alert("checking when it is called");
	  //round over, update the game and the scores
	this.channel.push("updateScore", { player: 1}).receive("ok", this.got_view.bind(this));
  }


  //for braodcasting messages
  handleClick(event){


	this.channel.push("sendMessage", { player: 1}).receive("ok", this.get_message.bind(this));
	var doc = document.getElementById("tbox").value;

	var li = document.createElement("li");
	li.appendChild(document.createTextNode(doc));
	document.getElementById("content").appendChild(li);
  }

  get_message(message){
console.log(message)
  }

  render() {
	  console.log(this.state.playerChance)
    return (
		<div>
			<div className = "row1">
				<h2>Aside Pile</h2>
				<div  id = "asidePile" draggable onDragStart = {(e) => this.handleDragStart(e)} onDrop = {(e) => this.handleDropToAsidePile(e)} onDragOver = {(e) => e.preventDefault()}>
					<AsidePile type = {this.state.asidePile[this.state.asidePile.length - 1][1]} value = {this.state.asidePile[this.state.asidePile.length - 1][0]}/>
				</div>
			</div>
			<div className = "row2">
				<h2>Remaining Pile</h2>
				<div id = "remainingPile" draggable onDragStart = {(e) => this.handleDragStart(e)}  onDrop = {(e) => e.preventDefault()} onDragOver = {(e) => e.preventDefault()}>
					<RemainingPile type = {this.state.remainingPile[1]} value = {this.state.remainingPile[0]}/>
				</div>
			</div>
			<div className = "rowTable">
			<table className = "table">
				<tbody>
					<tr>
						<th>
							Rounds
						</th>
						<th>
							Player 1
						</th>
						<th>
							Player 2
						</th>
					</tr>
					<tr>
						<td> Round 1</td>
						<td> {this.state.scores[0][0]}</td>
						<td>{this.state.scores[0][1]}</td>
					</tr>
					<tr>
						<td> Round 2</td>
						<td>{this.state.scores[1][0]}</td>
						<td>{this.state.scores[1][1]}</td>
					</tr>
					<tr>
						<td> Round 3</td>
						<td>{this.state.scores[2][0]}</td>
						<td>{this.state.scores[2][1]}</td>
					</tr>
					<tr>
						<td> Total</td>
						<td>{this.state.totalScore[0]} </td>
						<td> {this.state.totalScore[1]}</td>
					</tr>
					</tbody>
				</table>

			</div>

			<div className = "player1" draggable="false">
				<h2>Player 1</h2>
				<div>
					<div id = "p1c1" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[0][1]} value = {this.state.playerOneCards[0][0]}/></div>
					<div id = "p1c2" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[1][1]} value = {this.state.playerOneCards[1][0]}/></div>
					<div id = "p1c3" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[2][1]} value = {this.state.playerOneCards[2][0]}/></div>
				</div>
				<div>
					<div id = "p1c4" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[3][1]} value = {this.state.playerOneCards[3][0]}/></div>
					<div id = "p1c5" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[4][1]} value = {this.state.playerOneCards[4][0]}/></div>
					<div id = "p1c6" onDrop = {(e) => this.handleDropForPlayerOne(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerOneCards[5][1]} value = {this.state.playerOneCards[5][0]}/></div>
				</div>
			</div>
			<div className = "player2"  draggable="false">
				<h2>Player 2</h2>
				<div>
					<div id = "p2c1" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[0][1]} value = {this.state.playerTwoCards[0][0]}/></div>
					<div id = "p2c2" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[1][1]} value = {this.state.playerTwoCards[1][0]}/></div>
					<div id = "p2c3" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[2][1]} value = {this.state.playerTwoCards[2][0]}/></div>
				</div>
				<div>
					<div id = "p2c4" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[3][1]} value = {this.state.playerTwoCards[3][0]}/></div>
					<div id = "p2c5" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[4][1]} value = {this.state.playerTwoCards[4][0]}/></div>
					<div id = "p2c6" onDrop = {(e) => this.handleDropForPlayerTwo(e)} onDragOver = {(e) => e.preventDefault()}><Card type = {this.state.playerTwoCards[5][1]} value = {this.state.playerTwoCards[5][0]}/></div>
				</div>
			</div>

			
		</div>
    );
  }
}

class Card extends React.Component {

    constructor(props) {
      super(props);
      this.state = {
      type: props.type,
	  value: props.value,
	  drag: props.drag,
      flip: 1,
      };  
    }

    render(){
        return(
			<div className = "cardClass">
					<p>{this.props.type}</p>
					<p>{this.props.value}</p>
					<p>{this.props.flip}</p>
			</div>
			
        );
    }

}

function AsidePile(params){
	const items = []
	items.push(<Card type = {params.type} value = {params.value}/>);
	return items;
}

function RemainingPile(params){
	const items = []
	items.push(<Card type = {params.type} value = {params.value}/>);
	return items;
}

