<template>
  <div v-loading="loading">
    <form class="form-horizontal" _lpchecked="1">
      <div class="header p-10-0 mb-4"><h2>Basic Information</h2></div>
      <div class="row p-0-20">
        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="sadhak_profile.first_name"
              v-validate="'required'"
              data-vv-as="first name"
              type="text"
              name="first_name"
              id="first_name"
              class="form-control"
              >
            <label for="first_name" :class="sadhak_profile.first_name ? 'active' : ''">First Name *</label>
            <span class="small">As mentioned in your Photo ID proof</span>
            <span class="text-danger">{{ errors.first('first_name') }}</span>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="sadhak_profile.last_name"
              v-validate="'required'"
              data-vv-as="last name"
              type="text"
              name="last_name"
              id="last_name"
              class="form-control">
            <label for="last_name" :class="sadhak_profile.last_name ? 'active' : ''">Last Name *</label>
            <span class="small">As mentioned in your Photo ID proof</span>
            <span class="text-danger">{{ errors.first('last_name') }}</span>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <label for="mobile" class="active">Mobile</label>
            <vue-tel-input
              v-model="sadhak_profile.mobile"
              v-validate="'phoneOrEmail:email|mobile'"
              ref="mobile"
              name="mobile_number"
              :preferredCountries="['IN', 'US']"
            ></vue-tel-input>
            <span class="small">Either phone or email is required</span>
            <span class="text-danger">{{ errors.first('mobile_number') }}</span>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="sadhak_profile.email"
              v-validate="'phoneOrEmail:mobile|email'"
              ref="email"
              name="email"
              id="email"
              type="text"
              class="form-control"
            >
            <label for="email" :class="sadhak_profile.email ? 'active' : ''">Email</label>
            <span class="small">Either phone or email is required</span>
            <span class="text-danger">{{ errors.first('email') }}</span>
          </div>
        </div>
      </div>

      <div class="row p-0-20">
        <div class="col-sm-6 clearfix">
          <label>Gender</label><br>
          <el-radio-group v-model="sadhak_profile.gender">
            <el-radio :label="'male'"><i class="fa fa-male" aria-hidden="true"></i> Male</el-radio>
            <el-radio :label="'female'"><i class="fa fa-female" aria-hidden="true"></i> Female</el-radio>
          </el-radio-group>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="input-group date md-form display-table">
            <label class="active" v-if="sadhak_profile.date_of_birth">Date of Birth</label>
            <div class="form-line">
              <el-date-picker
                v-model="sadhak_profile.date_of_birth"
                clearable
                prefix-icon="false"
                name="date_of_birth"
                type="date"
                placeholder="Date of Birth">
              </el-date-picker>
            </div>
            <span class="input-group-addon">
              <i class="material-icons">date_range</i>
            </span>
          </div>
        </div>
      </div>

      <div class="header p-10-0 mb-4"><h2>Address</h2></div>
      <div class="row p-0-20">
        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="address.first_line"
              type="text" class="form-control" id="address_line_1" name="address_line_1">
            <label for="address_line_1" :class="address.first_line ? 'active' : ''">Address Line 1</label>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="address.second_line"
              type="text" class="form-control" id="address_Line_2" name="address_Line_2">
            <label for="address_Line_2" :class="address.second_line ? 'active' : ''">Address Line 2</label>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <label class="active" v-if="address.country_id">Country</label>
            <el-select
              v-model="address.country_id"
              filterable
              clearable
              reserve-keyword
              placeholder="Country"
              autocomplete="new-password"
              :loading="loading"
              @change="resetStateAndCity"
              name="country"
            >
              <el-option
                v-for="item in countryOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id">
              </el-option>
            </el-select>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <label class="active" v-if="address.state_id">State</label>
            <el-select
              v-model="address.state_id"
              filterable
              clearable
              reserve-keyword
              placeholder="State"
              autocomplete="new-password"
              :loading="loading"
              @change="resetCity"
              name="state"
              >
              <el-option
                v-for="item in stateOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id">
              </el-option>
              <span slot="empty">Please select a country first</span>
            </el-select>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <label class="active" v-if="address.city_id">City</label>
            <el-select
              v-model="address.city_id"
              filterable
              clearable
              reserve-keyword
              placeholder="City"
              autocomplete="new-password"
              :loading="loading"
              name="city"
              >
              <el-option
                v-for="item in cityOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id">
              </el-option>
              <span slot="empty">Please select a state first</span>
            </el-select>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form">
            <input
              v-model="address.postal_code"
              type="text" class="form-control" id="post_code" name="post_code">
            <label for="post_code"  :class="address.postal_code ? 'active' : ''">PostCode</label>
          </div>
        </div>

        <div class="col-sm-6 clearfix">
          <div class="md-form"  v-if="this.address.state_id == 99999">
            <input
              v-model="address.other_state"
              type="text" class="form-control" id="Other_State" name="Other_State" required="">
            <label for="Other_State" :class="address.other_state ? 'active' : ''">State Name</label>
          </div>
        </div>

        <div class="col-sm-6 clearfix" v-if="this.address.city_id == 999999">
          <div class="md-form">
            <input
            v-model="address.other_city"
            type="text" class="form-control" id="Other_City" name="Other_City" required="">
            <label for="Other_City" :class="address.other_city ? 'active' : ''">City Name</label>
          </div>
        </div>
      </div>

      <div class="form-group">
        <div class="col-sm-12 text-align-center">
          <div class="alert bg-red text-align-center" v-if="errorMessage">
            <i class="material-icons vertical-align-middle">close</i>
            {{ errorMessage }}
          </div>
          <div class="shivyog-btn">
            <button
              @click="submit"
              class="cta_button_small bg-red waves-effect"
            >
              <i class="fa fa-paper-plane-o ml-1"></i> SUBMIT
            </button>
          </div>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import VueTelInput from 'vue-tel-input'
import 'vue-tel-input/dist/vue-tel-input.css'
import { parsePhoneNumberFromString } from 'libphonenumber-js'

export default {
  components: {
    VueTelInput
  },
  props: {
    sadhakProfileId: String,
  },
  data: function () {
    return {
      sadhak_profile: {
        first_name: null,
        last_name: null,
        gender: null,
        date_of_birth: null,
        email: null,
        mobile: null,
      },
      address: {
        first_line: null,
        second_line: null,
        city_id: null,
        state_id: null,
        country_id: null,
        other_state: null,
        other_city: null,
        postal_code: null,
      },
      countryOptions: [],
      stateOptions: [],
      cityOptions: [],
      loading: false,
      errorMessage: null,
    }
  },
  created () {
    this.$validator.extend('phoneOrEmail',  {
      getMessage: () => 'phone or email must be provided',
      validate: (value, [otherValue]) => {
        return {
          valid: (!!value || !!otherValue), // or false
          data: {
            required: (!value && !otherValue),
          }
        }
      }
    }, {
      computesRequired: true,
      hasTarget: true
    })
    this.$validator.extend('mobile', {
      getMessage: field => 'invalid mobile number.',
      validate: value => {
        const phone = parsePhoneNumberFromString(value.toString())
        return phone ? phone.isValid() : false
      }
    });

    if (this.sadhakProfileId)
      this.$axios.get(`/sadhak_profiles/${this.sadhakProfileId}.json`)
        .then(response => {
          this.sadhak_profile = response.data.sadhak_profile
          this.address = response.data.address

          if (this.address.country_id)
            this.$axios.get(`/countries/${this.address.country_id}/states.json`)
              .then(response => {
                this.stateOptions = response.data
              })

          if (this.address.state_id)
            this.$axios.get(`/countries/${this.address.country_id}/states/${this.address.state_id}/cities.json`)
              .then(response => {
                this.cityOptions = response.data
              })
        })

  },
  mounted () {
    this.$axios.get('/countries.json')
      .then(response => {
        this.countryOptions = response.data
      })
  },
  computed: {
    submitUrl () {
      if (this.sadhakProfileId)
        return `/sadhak_profiles/${this.sadhakProfileId}.json`
      else
        return '/sadhak_profiles.json'
    },
    submitMethod () {
      return (this.sadhakProfileId ? 'PATCH' : 'POST')
    }
  },
  methods: {
    resetStateAndCity () {
      this.$axios.get(`/countries/${this.address.country_id}/states.json`)
        .then(response => {
          this.stateOptions = response.data
        })
      this.address.state_id = null
      this.address.city_id = null
      this.cityOptions = []
    },
    resetCity () {
      this.address.city_id = null
      this.$axios.get(`/countries/${this.address.country_id}/states/${this.address.state_id}/cities.json`)
        .then(response => {
          this.cityOptions = response.data
        })
    },
    submit (e) {
      e.preventDefault()
      this.$validator.validate().then(valid => {
        if (valid) {
          this.loading = true
          this.errorMessage = null

          let data = {
            sadhak_profile: this.sadhak_profile,
            address: this.address,
          }

          this.$axios({
            method: this.submitMethod,
            url: this.submitUrl,
            data: data
          }).then(response => {
              window.location.href = response.data.redirect_path
            })
            .catch(error => {
              this.loading = false
              this.errorMessage = error.response.data.message
            })
        }
      })
    }
  }
}
</script>

<style lang="scss">
.el-select {
  display: block;
}

.md-form input[type=text] {
  -webkit-box-sizing: border-box;
  box-sizing: border-box !important;
}

.el-date-editor.el-input,
.el-date-editor.el-input__inner {
  width: 100%;
}

.el-select,
.el-date-editor {
  .el-input__inner {
    padding: 0;
    height: 35px;
    line-height: 35px;

    &::placeholder {
      font-family: Ubuntu, sans-serif;
      font-size: 14px;
      color: #757575;
      font-weight: 300;
    }
  }
}

.vue-tel-input {
  border: none !important;

  &:focus-within {
    box-shadow: none !important;
  }

  .dropdown:focus {
    outline: none;
  }
}
</style>
