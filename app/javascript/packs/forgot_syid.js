import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import axios from 'axios'
import VeeValidate from 'vee-validate'
import vSelect from 'vue-select'
import 'vue-select/dist/vue-select.css'
import flatPickr from 'vue-flatpickr-component'
import ForgotSyid from '../ForgotSyid.vue'

Vue.prototype.$axios = axios
Vue.use(TurbolinksAdapter)
Vue.use(VeeValidate, {
  mode: 'agressive',
  events: 'change|blur'
})
Vue.component('v-select', vSelect)
Vue.component('flat-pickr', flatPickr)

document.addEventListener('turbolinks:load', () => {
  Vue.prototype.$axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  const element = document.getElementById('vue-forgot-syid')

  if (element != null) {
    const props = {}

    new Vue({
      el: element,
      render: h => h(ForgotSyid, { props })
    })
  }
})

// if (!Turbolinks) {
//   location.reload()
// }

// Turbolinks.dispatch('turbolinks:load')
