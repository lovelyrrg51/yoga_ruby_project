import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import axios from 'axios'
import VeeValidate from 'vee-validate'
import VueCountdown from '@chenfengyuan/vue-countdown'
import VerifySadhakProfile from '../VerifySadhakProfile.vue'

Vue.prototype.$axios = axios
Vue.use(TurbolinksAdapter)
Vue.use(VeeValidate)
Vue.component(VueCountdown.name, VueCountdown)

document.addEventListener('turbolinks:load', () => {
  Vue.prototype.$axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  const element = document.getElementById('vue-verify-sadhak-profile')

  if (element != null) {
    const props = {
      verifyPath: element.dataset.verifyPath,
      resendPath: element.dataset.resendPath,
      backPath: element.dataset.backPath,
    }

    new Vue({
      el: element,
      render: h => h(VerifySadhakProfile, { props })
    })
  }
})

if (!Turbolinks) {
  location.reload()
}

Turbolinks.dispatch('turbolinks:load')
