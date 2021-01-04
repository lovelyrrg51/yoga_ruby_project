<template>
  <div class="row clearfix member_input_div" :id="`member_input_div_1_${uiIndex}`">
    <div class="col-sm-12">
      <div class="row">
        <div class="col-sm-12">
          <div class="title">Please fill in the form below to register this member.</div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-12">
          <div class="card">
            <div class="body">
              <el-form class="form-horizontal" :model="newSadhakProfile" :rules="rules" ref="newSadhakProfile">
                <div class="header p-10-0"><h2>Basic Information</h2></div>
                <div class="row p-0-20">
                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" name="first_name" :id="`first_name_${uiIndex}`" class="form-control"
                             v-model="newSadhakProfile.firstName"
                             required
                             v-validate="'required'"
                             data-vv-as="first name"
                             autofocus
                      >
                      <label :for="`first_name_${uiIndex}`">First Name</label>
                      <span class="small">As mentioned in your Photo ID proof</span>
                      <span v-show="errors.has('first_name') && submitted" class="text-danger">{{ errors.first('first_name') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" name="last_name" :id="`last_name_${uiIndex}`" class="form-control"
                             v-model="newSadhakProfile.lastName"
                             required
                             v-validate="'required'"
                             data-vv-as="last name"
                      >
                      <label :for="`last_name_${uiIndex}`">Last Name</label>
                      <span class="small">As mentioned in your Photo ID proof</span>
                      <span v-show="errors.has('last_name') && submitted" class="text-danger">{{ errors.first('last_name') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <VueTelInput
                          name="mobile_number"
                          v-model="newSadhakProfile.mobile"
                          v-validate="'phoneOrEmail:email'"
                          ref="mobile"
                          :preferredCountries="['IN', 'US']"
                      />
                      <span class="small">Either phone or email is required</span>
                      <span v-show="errors.has('mobile_number') && submitted" class="text-danger">{{ errors.first('mobile_number') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" class="form-control" :id="`email_${uiIndex}`" name="email"
                             v-model="newSadhakProfile.email"
                             v-validate="'phoneOrEmail:mobile|email'"
                             ref="email"
                      >
                      <label :for="`email_${uiIndex}`">Email</label>
                      <span class="small">Either phone or email is required</span>
                      <span v-show="errors.has('email') && submitted"
                            class="text-danger">{{ errors.first('email') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <label>Gender *</label><br>
                    <el-radio-group v-model="newSadhakProfile.gender">
                      <el-radio :label="'male'"><i class="fa fa-male" aria-hidden="true"></i> Male</el-radio>
                      <el-radio :label="'female'"><i class="fa fa-female" aria-hidden="true"></i> Female</el-radio>
                    </el-radio-group>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <div class="input-group display-table date md-form" :id="`datepickerContainerId_${uiIndex}`">
                        <div class="form-line sy-form-line">
                          <input type="text" class="form-control sy-date" placeholder="Date of Birth" name="birthdate"
                                 v-model="newSadhakProfile.dateOfBirth"
                          >
                        </div>
                        <span class="input-group-addon">
                          <i class="material-icons">date_range</i>
                      </span>
                      </div>
                      <span v-show="errors.has('birthdate') && submitted && !newSadhakProfile.dateOfBirth "
                            class="sy-text-danger">{{ errors.first('birthdate') }}</span>
                    </div>
                  </div>
                </div>

                <div class="header p-10-0"><h2>Address</h2></div>
                <div class="row p-0-20">
                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" class="form-control" :id="`address_line_1_${uiIndex}`"
                             name="address_line_1"
                             v-model="newSadhakProfile.address"
                      >
                      <label :for="`address_line_1_${uiIndex}`">Address Line 1</label>
                      <span v-show="errors.has('address_line_1') && submitted" class="text-danger">{{ errors.first('address_line_1') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" class="form-control" :id="`address_line_2_${uiIndex}`"
                             name="address_line_2"
                             v-model="newSadhakProfile.address2"
                      >
                      <label :for="`address_line_2_${uiIndex}`">Address Line 2</label>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <label class="active" v-if="newSadhakProfile.country">Country</label>
                      <el-form-item prop="country">
                        <el-select
                            v-model="newSadhakProfile.country"
                            filterable
                            reserve-keyword
                            placeholder="Country"
                            :loading="loading"
                            @change="resetStateAndCity"
                            name="country"
                            autocomplete="new-password"
                        >
                          <el-option
                              v-for="item in countryOptions"
                              :key="item.id"
                              :label="item.name"
                              :value="item.id">
                          </el-option>
                        </el-select>
                      </el-form-item>
                      <span v-show="errors.has('country') && submitted" class="text-danger">{{ errors.first('country') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <label class="active" v-if="newSadhakProfile.state">State</label>
                      <el-form-item prop="state">
                        <el-select
                            v-model="newSadhakProfile.state"
                            filterable
                            reserve-keyword
                            placeholder="State"
                            :loading="loading"
                            @change="resetCity"
                            name="state"
                            autocomplete="new-password"
                        >
                          <el-option
                              v-for="item in stateOptions"
                              :key="item.id"
                              :label="item.name"
                              :value="item.id">
                          </el-option>
                          <span slot="empty">Please select a country first</span>
                        </el-select>
                      </el-form-item>
                      <span v-show="errors.has('state') && submitted"
                            class="text-danger">{{ errors.first('state') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <label class="active" v-if="newSadhakProfile.city">City</label>
                      <el-form-item prop="city">
                        <el-select
                            v-model="newSadhakProfile.city"
                            filterable
                            reserve-keyword
                            placeholder="City"
                            :loading="loading"
                            name="city"
                            autocomplete="new-password"
                        >
                          <el-option
                              v-for="item in cityOptions"
                              :key="item.id"
                              :label="item.name"
                              :value="item.id">
                          </el-option>
                          <span slot="empty">Please select a state first</span>
                        </el-select>
                      </el-form-item>
                      <span v-show="errors.has('city') && submitted"
                            class="text-danger">{{ errors.first('city') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix" v-if="this.newSadhakProfile.state == 99999">
                    <div class="md-form">
                      <input
                          v-model="newSadhakProfile.otherState"
                          type="text" class="form-control" :id="`other_state_${uiIndex}`" name="other_state" required
                          v-validate="'required'"
                      >
                      <label :for="`other_state_${uiIndex}`">State Name</label>
                      <span v-show="errors.has('other_state') && submitted" class="text-danger">{{ errors.first('other_state') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix" v-if="newSadhakProfile.city == 999999">
                    <div class="md-form">
                      <input
                          v-model="newSadhakProfile.otherCty"
                          type="text" class="form-control" :id="`other_city_${uiIndex}`" name="other_city" required
                          v-validate="'required'"
                      >
                      <label :for="`other_city_${uiIndex}`">City Name</label>
                      <span v-show="errors.has('other_city') && submitted" class="text-danger">{{ errors.first('other_city') }}</span>
                    </div>
                  </div>

                  <div class="col-sm-6 clearfix">
                    <div class="md-form">
                      <input type="text" class="form-control" :id="`post_code_${uiIndex}`" name="post_code"
                             v-model="newSadhakProfile.postalCode"
                      >
                      <label :for="`post_code_${uiIndex}`">PostCode</label>
                      <span v-show="errors.has('post_code') && submitted" class="text-danger">{{ errors.first('post_code') }}</span>
                    </div>
                  </div>
                </div>

                <div class="form-group">
                  <div class="col-sm-12 text-align-center">
                    <div class="alert bg-red text-align-center" v-show="errorMessage && submitted">
                      <i class="material-icons vertical-align-middle">close</i>
                      {{ errorMessage }}
                    </div>
                  </div>
                </div>
              </el-form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Axios from 'axios'
  import {mapState} from 'vuex'
  import VueTelInput from 'vue-tel-input'

  export default {
    props: {
      id: Number
    },
    components: {
      VueTelInput
    },
    data: function () {
      return {
        newSadhakProfile: {
          firstName: '',
          lastName: '',
          dateOfBirth: '',
          email: '',
          address: '',
          address2: '',
          city: null,
          state: null,
          country: null,
          gender: null,
          mobile: '',
          postalCode: '',
          otherState: null,
          otherCity: null,
        },
        rules: {
          country: [
            {required: false, message: 'Please select your country.', trigger: 'change'}
          ],
          state: [
            {required: false, message: 'Please select your state.', trigger: 'change'}
          ],
          city: [
            {required: false, message: 'Please select your city.', trigger: 'change'}
          ]
          // dateOfBirth: [
          //   {required: true, message: 'Please select your birth date.', trigger: 'change'}
          // ],
        },
        submitted: false,
        countryOptions: [],
        stateOptions: [],
        cityOptions: [],
        loading: false
      }
    },
    created() {
      this.$validator.extend('phoneOrEmail', {
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
    },
    mounted() {
      //Bootstrap datepicker plugin
      const datepickerId = `#datepickerContainerId_${this.uiIndex}`
      $(datepickerId).datepicker({
        autoclose: true,
        container: datepickerId,
        format: 'yyyy-mm-dd'
      }).on(
        'changeDate', () => {
          this.newSadhakProfile.dateOfBirth = $(datepickerId + ' input').val();
        }
      );

      Axios.get('/countries.json')
        .then(response => {
          this.countryOptions = response.data
        })
    },
    computed: {
      firstNameId: function () {
        return "firstName_" + this.uiIndex
      },
      ...mapState({
        errorMessage(state) {
          return state.members[this.id].newSadhakProfile.error
        },
        uiIndex(state) {
          return state.members[this.id]._id
        }
      })
    },
    methods: {
      resetStateAndCity() {
        Axios.get(`/countries/${this.newSadhakProfile.country}/states.json`)
          .then(response => {
            this.stateOptions = response.data
          })
        this.newSadhakProfile.state = null
        this.newSadhakProfile.city = null
        this.cityOptions = []
      },
      resetCity() {
        this.newSadhakProfile.city = null
        Axios.get(`/countries/${this.newSadhakProfile.country}/states/${this.newSadhakProfile.state}/cities.json`)
          .then(response => {
            this.cityOptions = response.data
          })
      },
      resetForm: function () {
        Object.assign(this.newSadhakProfile, {
          firstName: '',
          lastName: '',
          dateOfBirth: '',
          email: '',
          address: '',
          address2: '',
          city: null,
          state: null,
          country: null,
          gender: 'male',
          mobile: '',
          postalCode: '',
          otherState: null,
          otherCity: null,
        })
        this.submitted = false
        this.$refs["newSadhakProfile"].resetFields();
        // Todo reset vee-validate
      },
      validate: function () {
        return new Promise(async (resolve, reject) => {
            try {
              const valid = await this.$validator.validateAll()
              this.submitted = true
              // apply validation css on element ui
              /* await this.$refs["newSadhakProfile"].validate() */
              if (valid) {
                const id = this.id
                this.$store.commit('updateNewSadhakProfile',
                  {id, newSadhakProfile: this.newSadhakProfile}
                )
              }
              resolve(valid)
            } catch (e) {
              console.log(e)
              resolve(false)
            }
          }
        );
      }
    }
  }
</script>

<style lang="scss">
  .el-select {
    display: block;
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

  .md-form input[type=text] {
    -webkit-box-sizing: border-box;
    box-sizing: border-box !important;
  }

  .el-date-editor.el-input,
  .el-date-editor.el-input__inner {
    width: 100%;
  }

  .form-control.is-invalid,
  .was-validated .form-control:invalid {
    padding-right: 0;
  }

  .form-control.is-valid,
  .was-validated .form-control:valid {
    padding-right: 0;
  }

  .el-form-item.is-error .el-input__inner,
  .el-form-item.is-error .el-input__inner:focus,
  .el-form-item.is-error .el-textarea__inner,
  .el-form-item.is-error .el-textarea__inner:focus,
  .el-message-box__input input.invalid,
  .el-message-box__input input.invalid:focus {
    border-color: #dc3545;
  }

  .input-group.date {
    margin-bottom: 0;
  }

  .was-validated {
    .sy-text-danger {
      width: 100%;
      margin-top: .25rem;
      font-size: 80%;
      color: #dc3545;
    }

    .sy-form-line {
      border-bottom: none !important;
    }

    .sy-date {
      &:invalid {
        border-bottom: 1px solid #dc3545 !important;
      }

      &:valid {
        border-bottom: 1px solid #28a745 !important;
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
