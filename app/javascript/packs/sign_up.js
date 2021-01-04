import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import axios from 'axios'
import VeeValidate from 'vee-validate'
import SignUp from '../SignUp.vue'

Vue.prototype.$axios = axios
Vue.use(TurbolinksAdapter)
Vue.use(VeeValidate)

document.addEventListener('turbolinks:load', () => {
  Vue.prototype.$axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  const element = document.getElementById('vue-sign-up')

  if (element != null) {
    new Vue({
      el: element,
      render: h => h(SignUp, {})
    })
  }
})

if (!Turbolinks) {
  location.reload()
}

Turbolinks.dispatch('turbolinks:load')
