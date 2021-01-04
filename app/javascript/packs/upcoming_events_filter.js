import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import axios from 'axios'
import vSelect from 'vue-select'
import 'vue-select/dist/vue-select.css'
import flatPickr from 'vue-flatpickr-component'
import UpcomingEventsFilter from '../UpcomingEventsFilter.vue'

Vue.prototype.$axios = axios
Vue.use(TurbolinksAdapter)
Vue.component('v-select', vSelect)
Vue.component('flat-pickr', flatPickr)

document.addEventListener('turbolinks:load', () => {
  Vue.prototype.$axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  const element = document.getElementById('vue-upcoming-events-filter')

  if (element != null) {
    const props = {
      initialStartDate: element.dataset.startDate,
      initialEndDate: element.dataset.endDate,
      initialCountryId: element.dataset.countryId,
      initialStateId: element.dataset.stateId,
      initialCityId: element.dataset.cityId,
      initialGracedBy: element.dataset.gracedBy,
    }

    new Vue({
      el: element,
      render: h => h(UpcomingEventsFilter, { props })
    })
  }
})

if (!Turbolinks) {
  location.reload()
}

Turbolinks.dispatch('turbolinks:load')
