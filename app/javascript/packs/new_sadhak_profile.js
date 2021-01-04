import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import axios from 'axios'
import ElementUI from 'element-ui'
import VeeValidate from 'vee-validate'
import locale from 'element-ui/lib/locale/lang/en'
import 'element-ui/lib/theme-chalk/index.css'
import 'vue-tel-input/dist/vue-tel-input.css'
import NewSadhakProfile from '../NewSadhakProfile.vue'

Vue.prototype.$axios = axios
Vue.use(TurbolinksAdapter)
Vue.use(ElementUI, { locale })
Vue.use(VeeValidate)

document.addEventListener('turbolinks:load', () => {
  Vue.prototype.$axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  const element = document.getElementById('vue-new-sadhak-profile')

  if (element != null) {
    const props = {
      sadhakProfileId: element.dataset.sadhakProfileId,
    }

    new Vue({
      el: element,
      render: h => h(NewSadhakProfile, { props })
    })
  }
})

// if (!Turbolinks) {
//   location.reload()
// }

// Turbolinks.dispatch('turbolinks:load')
