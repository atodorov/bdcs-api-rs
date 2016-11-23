import React, { PropTypes } from 'react';
import constants from '../../core/constants';

class Actions extends React.Component {

  state = { actions: [] };


  componentDidMount() {
  }

  componentDidUpdate() {
  }

  componentWillUnmount(){
  }

  getComptypes() {
		let that = this;
		fetch(constants.get_recipeactions_url).then(r => r.json())
			.then(data => {
				that.setState({actions : data})
			})
			.catch(e => console.log("Booo"));
	}


  render() {
    // const { Buttons } = this.props;
    // const { MenuItems } = this.props;
    const { className } = this.props;
    //const { actions } = this.props;

    return (
      <div className={className}>
        {this.state.actions.map(function(action,i) {
           if (action.type == "button") {
            return <button key={i} className="btn btn-default">{ action.label }</button>;
          }
        }.bind(this))}
        <div className="dropdown dropdown-kebab-pf pull-right">
          <button className="btn btn-link dropdown-toggle" type="button" id="dropdownKebab" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
            <span className="fa fa-ellipsis-v"></span>
          </button>
          <ul className="dropdown-menu dropdown-menu-right" aria-labelledby="dropdownKebab">
            {this.state.actions.map(function(action,i) {
               if (action.type == "menu") {
                return <li key={i}><a href="#">{ action.label }</a></li>;
              }
            }.bind(this))}
          </ul>
        </div>
      </div>
    )
  }


}

export default Actions;
