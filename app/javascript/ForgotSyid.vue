<template>
  <div class="container vld-parent">
    <loading
      :active.sync="loading"
      :can-cancel="false"
      :color="'#BC0D0F'"
      :loader="'bars'"
      :is-full-page="false"
    ></loading>

    <div class="row clearfix">

      <div class="col-sm-12">
          <div class="card">
              <div class="body">
                  <div>
      <ul id="tabs" class="nav nav-tabs" role="tablist">
        <li @click="tab = 1" key="email-mobile-input" class="nav-item waves-effect waves-light">
          <a id="tab-search_by_email_phone" href="#pane-search_by_email_phone" class="nav-link show active" data-toggle="tab" role="tab" aria-selected="true">Search by Email/Phone</a>
        </li>
        <li @click="tab = 2" key="details-input" class="nav-item waves-effect waves-light">
          <a id="tab-search_by_details" href="#pane-search_by_details" class="nav-link show" data-toggle="tab" role="tab" aria-selected="false">Search by Details</a>
        </li>
        </ul>
      <div id="content" class="tab-content" role="tablist">
        <div id="pane-search_by_email_phone" class="tab-pane fade active show" role="tabpanel" aria-labelledby="tab-search_by_email_phone">
          <div class="card-header" role="tab" id="heading-search_by_email_phone">

          <a @click="tab = 1" data-toggle="collapse" href="#collapse-search_by_email_phone" aria-expanded="true" aria-controls="collapse-search_by_email_phone">
              Search by Email/Phone
            </a>

          </div>
          <div id="collapse-search_by_email_phone" class="collapse show" role="tabpanel" data-parent="#content" aria-labelledby="heading-search_by_email_phone">
            <form v-if="tab == 1" class="form-horizontal p-10-0">
            <div class="row">
            <div class="col-sm-6 clearfix">
              <div class="input-group display-table">
                <label for="Search_By" class="control-label">Search by</label>
                <div class="gender-radio-btn">
                  <input type="radio" id="email" v-model="mode" value="email" class="radio-col-red with-gap">
                  <label for="email"><i class="fa fa-envelope-o" aria-hidden="true"></i>&nbsp;Email</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" id="mobile" v-model="mode" value="mobile" class="radio-col-red with-gap">
                  <label for="mobile"><i class="fa fa-mobile-phone" aria-hidden="true"></i>&nbsp;Phone</label>
                </div>
              </div>
            </div>

            <div class="col-sm-6">
              <div class="md-form search_email box" v-if="mode == 'email'">
                <input
                  v-model="email"
                  v-validate="'required|email'"
                  key="email-input"
                  type="email" class="form-control" id="email" name="email">
                <label for="email" :class="email ? 'active' : ''">Email *</label>
                <span class="text-danger">{{ errors.first('email') }}</span>
              </div>

              <div class="md-form search_mobile box" v-if="mode == 'mobile'">
                <vue-tel-input
                  v-model="mobile"
                  v-validate="'required|mobile'"
                  ref="mobile"
                  name="mobile"
                  :preferredCountries="['IN', 'US']"
                ></vue-tel-input>
                <span class="text-danger">{{ errors.first('mobile') }}</span>
              </div>
            </div>

            <div class="col-sm-12 clearfix">
            <div class="form-group">
              <div class="col-sm-12 text-align-center">
                <div class="shivyog-btn">
                  <button @click="searchByMobileOrEmail"
                    class="cta_button_small bg-red waves-effect"><i class="material-icons">search</i> SEARCH</button>
                </div>
              </div>
            </div>
            </div>
            </div>
          </form>

          <div class="row clearfix family_profiles">
            <div class="col-sm-12">
              <div class="alert bg-green text-align-center" v-if="successMessage">
                <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;
                {{ successMessage }}
              </div>

              <div class="alert bg-red text-align-center" v-if="errorMessage">
                <i class="material-icons vertical-align-middle">close</i>&nbsp;
                {{ errorMessage }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div id="pane-search_by_details" class="tab-pane fade" role="tabpanel" aria-labelledby="tab-search_by_details">
        <div class="card-header" role="tab" id="heading-search_by_details">

          <a @click="tab = 2" data-toggle="collapse" href="#collapse-search_by_details" aria-expanded="false" aria-controls="collapse-search_by_details">
              Search by Details
            </a>

          </div>
          <div id="collapse-search_by_details" class="collapse" role="tabpanel" data-parent="#content" aria-labelledby="heading-search_by_details">
          <form v-if="tab == 2" class="form-horizontal p-10-0">
              <div class="row">
              <div class="col-sm-6 clearfix">
                <div class="md-form">
                <input
                  v-model="first_name"
                  v-validate="'required'"
                  data-vv-as="First Name"
                  type="text" class="form-control" id="first_name" name="first_name">
                <label for="first_name" :class="first_name ? 'active' : ''">First Name *</label>
                <span class="text-danger">{{ errors.first('first_name') }}</span>
                </div>
              </div>

              <div class="col-sm-6 clearfix">
                <div class="md-form">
                <input
                  v-model="last_name"
                  type="text" class="form-control" id="last_name" name="last_name">
                <label for="last_name" :class="last_name ? 'active' : ''">Last Name</label>
                </div>
              </div>

              <div class="col-sm-6 clearfix">
                <div class="input-group display-table">
                  <div class="md-form md-event-input input-group date-input">
                    <label :class="date_of_birth ? 'active' : ''">Date of Birth</label>
                    <flat-pickr
                      v-model="date_of_birth"
                      class="form-control"
                      :config="dateConfig"
                    ></flat-pickr>

                    <i v-if="date_of_birth"
                          @click="date_of_birth = ''"
                          style="z-index: 10; position:absolute; color: #BC0D0F; bottom: 10px; right: 10px; cursor: grab;"
                          class="material-icons" aria-hidden="true">clear</i>
                  </div>
                </div>
              </div>

              <div class="col-sm-6 clearfix">
                <div class="md-form">
                  <label :class="country ? 'active' : ''">Country</label>
                  <v-select
                    v-model="country"
                    label="name"
                    :options="countryOptions"
                    @input="resetStateAndCity"
                    :resetOnOptionsChange="true"
                  >
                  </v-select>
                </div>
              </div>

              <div class="col-sm-6 clearfix">
                <div class="md-form">
                  <label :class="state ? 'active' : ''">State</label>

                  <v-select
                    v-model="state"
                    label="name"
                    :options="stateOptions"
                    @input="resetCity"
                    :resetOnOptionsChange="true"
                  />
                </div>
              </div>

              <div class="col-sm-6 clearfix">
                <div class="md-form">
                  <label :class="city ? 'active' : ''">City</label>
                  <v-select
                    v-model="city"
                    label="name"
                    :options="cityOptions"
                    :resetOnOptionsChange="true"
                  />
                </div>
              </div>

              <div class="col-sm-12 clearfix">
              <div class="form-group">
                <div class="col-sm-12 text-align-center">
                  <div class="shivyog-btn">
                    <button
                      @click="searchByDetails"
                      class="cta_button_small bg-red waves-effect">
                      <i class="material-icons">search</i>  SEARCH
                    </button>
                  </div>
                </div>
              </div>
              </div>
              </div>
            </form>
          </div>

          <div class="row clearfix family_profiles">
            <div class="col-sm-12">
              <div class="alert bg-green text-align-center" v-if="successMessage">
                <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;
                {{ successMessage }}
              </div>

              <div class="alert bg-red text-align-center" v-if="errorMessage">
                <i class="material-icons vertical-align-middle">close</i>&nbsp;
                {{ errorMessage }}
              </div>
            </div>
          </div>

                          </div>
                      </div>
                  </div>
              </div>
          </div>
      </div>
  </div>

</div>
</template>

<script>
import VueTelInput from 'vue-tel-input'
import 'vue-tel-input/dist/vue-tel-input.css'
import Loading from 'vue-loading-overlay'
import 'vue-loading-overlay/dist/vue-loading.css'
import { parsePhoneNumberFromString } from 'libphonenumber-js'

export default {
  components: {
    VueTelInput,
    Loading
  },
  props: {
  },
  data: () => {
    return {
      loading: false,
      tab: 1, // 1 = email/mobile, 2 = details
      mode: 'email',
      email: null,
      mobile: null,
      errorMessage: null,
      successMessage: null,
      first_name: null,
      last_name: null,
      date_of_birth: null,
      country: null,
      state: null,
      city: null,
      countryOptions: [],
      stateOptions: [],
      cityOptions: [],
      dateConfig: {
        maxDate: 'today',
        altInput: true,
        altFormat: 'F j, Y',
        wrap: true,
      }
    }
  },
  created () {
    this.$validator.extend('mobile', {
      getMessage: field => 'invalid mobile number.',
      validate: value => {
        const phone = parsePhoneNumberFromString(value.toString())
        return phone ? phone.isValid() : false
      }
    })
  },
  mounted () {
    this.$axios.get('/countries.json')
      .then(response => {
        this.countryOptions = response.data
      })
  },
  computed: {
    details() {
      let details = {}
      if (this.first_name)
        details.first_name = this.first_name
      if (this.last_name)
        details.last_name = this.last_name
      if (this.date_of_birth)
        details.date_of_birth = this.date_of_birth
      if (this.country)
        details.country_id = this.country.id
      if (this.state)
        details.state_id = this.state.id
      if (this.city)
        details.city_id = this.city.id

      return details
    }
  },
  methods: {
    searchByMobileOrEmail (e) {
      e.preventDefault()
      switch (this.mode) {
        case 'email':
          this.searchByEmail()
          break
        case 'mobile':
          this.searchByMobile()
          break
        default:
          // code block
      }
    },
    searchByEmail () {
      this.$validator.validate().then(valid => {
        if (!valid) { return }

        this.loading = true
        this.errorMessage = null
        this.successMessage = null

        this.$axios.post('/forgot_syid/search_by_email', {
          email: this.email
        })
        .then(response => {
          this.successMessage = 'SYID list has been sent to you. Please check your email.'
        })
        .catch(error => {
          if (error.response.status == 503)
            this.errorMessage = 'You have sent too many requests. Please try again after 5 minutes.'
          else
            this.errorMessage = error.response.data.message
        })
        .then(() => {
          this.loading = false
        })
      })
    },
    searchByMobile () {
      this.$validator.validate().then(valid => {
        if (!valid) { return }

        this.loading = true
        this.errorMessage = null
        this.successMessage = null

        this.$axios.post('/forgot_syid/search_by_mobile', {
          mobile: this.mobile
        })
        .then(response => {
          this.successMessage = 'SYID list has been sent to you. Please check your mobile.'
        })
        .catch(error => {
          if (error.response.status == 503)
            this.errorMessage = 'You have sent too many requests. Please wait for some time before trying again.'
          else
            this.errorMessage = error.response.data.message
        })
        .then(() => {
          this.loading = false
        })
      })
    },
    searchByDetails (e) {
      e.preventDefault()

      this.$validator.validate().then(valid => {
        if (!valid) { return }

        this.loading = true
        this.errorMessage = null
        this.successMessage = null

        this.$axios.post('/forgot_syid/search_by_details', this.details)
          .then(response => {
            this.successMessage = response.data.message
          })
          .catch(error => {
            if (error.response.status == 503)
              this.errorMessage = 'You have sent too many requests. Please wait for some time before trying again.'
            else
              this.errorMessage = error.response.data.message
          })
          .then(() => {
            this.loading = false
          })
      })
    },
    resetStateAndCity () {
      if (this.country && this.country.id)
        this.$axios.get(`/countries/${this.country.id}/states.json`)
          .then(response => {
            this.stateOptions = response.data
          })
      else
      this.stateOptions = []
      this.cityOptions = []
    },
    resetCity () {
      if (this.state && this.state.id)
        this.$axios.get(`/countries/${this.country.id}/states/${this.state.id}/cities.json`)
          .then(response => {
            this.cityOptions = response.data
          })
      else
        this.cityOptions = []
    },
  }
}
</script>

<style lang="scss" scoped>
.md-form input[type=text] {
  -webkit-box-sizing: border-box;
  box-sizing: border-box !important;
}

.vue-tel-input {
  border: none !important;

  &:focus-within {
    box-shadow: none !important;
  }
}

.date_input {
  border-bottom: 1px solid #ced4da !important;
}

.v-select {
  &::v-deep .vs__dropdown-toggle {
    border: 0;

    input.vs__search {
      height: 21px;
      padding-top: 5px;
      padding-bottom: 8px;
    }

    span.vs__selected {
      font-family: 'Ubuntu', sans-serif;
      font-size: 14px;
      font-weight: 400;
      color: #495057;
      border: none;
      border-radius: 0;
      margin-left: 0;
      margin-right: 0;
      border-bottom: 1px solid #ced4da;
    }

    ::placeholder {
      font-family: 'Ubuntu', sans-serif;
      font-size: 14px;
      font-weight: 400;
      color: #757575;
    }
  }
}
</style>
