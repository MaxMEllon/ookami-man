import _ from 'lodash';

export default class SettingAction {

  addListenChangePeople() {
    const button = document.querySelector('button.deside-people');
    button.onclick = () => {
      const peopleText = document.querySelector('input.people').value;
      let people = 0;
      people = parseInt(peopleText);
      if (_.isNaN(people)) {
        people = 0;
        alert('数字で入力してください');
      }
      this.appendUserInputForm(people);
      return false;
    }
  }

  appendUserInputForm(peopleNum) {
    const parent = document.querySelector('fieldset.people');
    for (let i = 0; i < peopleNum; i++) {
      let input = document.createElement('input');
      input.name = i;
      input.className = 'user-name';
      parent.appendChild(input);
    }
    let br = document.createElement('br');
    parent.appendChild(br);
    let button = document.createElement('button');
    button.className = 'pure-button pure-button-primary';
    button.innerText = 'ユーザー登録';
    parent.appendChild(button);
  }
}
