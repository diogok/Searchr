package searchr;

import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.text.Text;
import javafx.scene.paint.Color;
import javafx.scene.layout.VBox;
import javafx.scene.control.TextBox;
import javafx.scene.control.Button;
import javafx.scene.layout.HBox;
import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import javafx.data.feed.atom.AtomTask;
import javafx.data.feed.atom.Entry;
import javafx.data.feed.atom.Feed;
import java.lang.Exception;
import javafx.scene.layout.ClipView;
import javafx.scene.input.MouseEvent;


class SearchLine extends CustomNode {

	public-init var profileUrl: String ;
	public-init var user: String ;
	public-init var text: String;
	public var width: Number ;

	override function create(): Node {
		return HBox {
			spacing: 5
			content: [
				ImageView {
					image: Image {
                                            url: profileUrl
                                            , width: 54
                                            , height: 54
                                            , backgroundLoading: true
                                            , placeholder: Image {
                                                        url: "{__DIR__}placeholder.png"
                                                        width: 54
                                                        height: 54
                                                    }
					}
				},
				Text {
					content: "{user}: {text}"
					wrappingWidth: bind width - 60
                                        fill: Color.WHITESMOKE
				}
			]
		}
	}
}

class Tweet {
	public var profileImage :String;
	public var user: String ;
	public var text: String ;
}

var tweets: Tweet[];

def tweetList: VBox = VBox { spacing: 5 , content: bind for ( tweet in tweets) {
								SearchLine{
									profileUrl: tweet.profileImage
									user: tweet.user
									text: tweet.text
									width: bind scene.width - 15
								} } }

var current: AtomTask ;

function doSearch(): Void {
    if(current != null) {    current.stop(); }
    current = AtomTask {
        interval: 1m
        location: "http://search.twitter.com/search.atom?q={input.text}"
        onFeed: function(feed: Feed) {
            println(feed.title);
            delete tweets;
        }
        onStart: function() {
            println("started")
        }
        onException: function(e: Exception) {
            e.printStackTrace();
        }
        onEntry: function(item: Entry) {
                println(item.title.text);
            insert Tweet {
                profileImage: item.links[1].href
                text: item.title.text
                user: item.authors[0].name
            } into tweets ;
        }
    };
    current.start();
    input.text = "";
}

def clip: ClipView = ClipView {
	clipY: 0
	clipX: 0
	node: tweetList
	height: bind scene.height - 30
	width: bind scene.width
}

def input: TextBox = TextBox { promptText: "Search..." , action: doSearch, columns: 30};
def button: Button = Button { text: "Search", action: doSearch };

def searchBar: HBox = HBox { spacing: 5, content: [ input, button] }
def container: VBox = VBox { translateX: 10, translateY: 5, spacing: 5, content: [ searchBar, clip ] }
def scene: Scene = Scene {
			fill: Color.rgb(51,51,51)
			content: [ container ]
			}



var stage: Stage ;

function run() {
	stage = Stage {
		title: "Hello JavaFx"
		width: 350
		height: 500
		scene: scene
	}
}