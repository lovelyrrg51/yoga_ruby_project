<template>
  <section class="event-filter event_filter_box">
    <div class="container">
      <div class="row">
        <div class="col-sm-12">
          <div id="accordion">
            <div class="card-header" id="headingOne">
              <h5 class="mb-0">
            <button class="btn btn-link waves-effect waves-light" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
            FILTER
            </button>
            </h5>
            </div>
            <div id="collapseOne" class="events_col collapse show" aria-labelledby="headingOne" data-parent="#accordion" style="">
              <form _lpchecked="1">
                <div class="row">
                  <div class="col-md-4 col-sm-12 col-xs-12">
                    <div class="md-form">
                      <v-select
                        :key="'country' + address_country_id_eq"
                        v-model="country"
                        label="name"
                        :options="countryOptions"
                        @input="resetStateAndCityOptions"
                        placeholder="Country"
                        :resetOnOptionsChange="true"
                      >
                      </v-select>
                    </div>
                  </div>

                  <div class="col-md-4 col-sm-12 col-xs-12">
                    <div class="md-form">
                      <v-select
                        :key="'state' + address_state_id_eq"
                        v-model="state"
                        label="name"
                        :options="stateOptions"
                        @input="resetCityOptions"
                        placeholder="State"
                        :disabled="!address_country_id_eq"
                        :resetOnOptionsChange="true"
                      ></v-select>
                    </div>
                  </div>

                  <div class="col-md-4 col-sm-12 col-xs-12">
                    <div class="md-form">
                      <v-select
                        :key="'city' + address_city_id_eq"
                        v-model="city"
                        label="name"
                        :options="cityOptions"
                        placeholder="City"
                        :disabled="!address_state_id_eq"
                        :resetOnOptionsChange="true"
                      ></v-select>
                    </div>
                  </div>

                  <div class="col-md-4 col-sm-12 col-xs-12">
                    <div class="md-form">
                      <v-select
                        v-model="graced_by_eq"
                        label="name"
                        :options="gracedByOptions"
                        placeholder="Event graced by"
                      ></v-select>
                    </div>
                  </div>

                  <div class="col-md-8 col-sm-12 col-xs-12">
                    <div class="input-group display-table">
                      <div class="row">
                      <div class="col-sm-6">
                        <div class="md-form md-event-input input-group date-input">
                          <flat-pickr
                            v-model="event_start_date_gteq"
                            placeholder="Start date"
                            class="form-control"
                            :config="startDateConfig"
                          ></flat-pickr>
                          <i v-if="event_start_date_gteq"
                            @click="event_start_date_gteq = ''"
                            style="z-index: 10; color: #BC0D0F; top: 14px; cursor: grab;"
                            class="material-icons" aria-hidden="true">clear</i>
                        </div>
                      </div>

                      <div class="col-sm-6">
                      <div class="md-form md-event-input input-group date-input">
                        <flat-pickr
                            v-model="event_end_date_lteq"
                            placeholder="End date"
                            class="form-control"
                            :config="endDateConfig"
                        ></flat-pickr>
                        <i v-if="event_end_date_lteq"
                          @click="event_end_date_lteq = ''"
                          style="z-index: 10; color: #BC0D0F; top: 14px; cursor: grab;"
                          class="material-icons" aria-hidden="true">clear</i>
                      </div>
                      </div>
                    </div>
                      </div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-2 offset-md-4 col-sm-6 col-xs-6">
                    <div class="shivyog-btn">
                      <a href="/events/upcoming" class="btn cta_button_small bg-red waves-effect">
                        <i class="material-icons">clear</i>&nbsp;Clear
                      </a>
                    </div>
                  </div>
                  <div class="col-md-2 col-sm-6 col-xs-6">
                    <div class="shivyog-btn">
                      <a href="javascript:;" @click="submit" class="btn cta_button_small bg-red waves-effect">
                        <i class="material-icons">search</i>&nbsp;Filter
                      </a>
                    </div>
                  </div>
                </div>
              </form>
              <form id="js-hidden-form" method="GET" action="/events/upcoming">
                <input type="hidden" name="q[address_country_id_eq]" :value="address_country_id_eq">
                <input type="hidden" name="q[address_state_id_eq]" :value="address_state_id_eq">
                <input type="hidden" name="q[address_city_id_eq]" :value="address_city_id_eq">
                <input type="hidden" name="q[graced_by_eq]" :value="graced_by_eq">
                <input type="hidden" name="q[event_start_date_gteq]" :value="event_start_date_gteq">
                <input type="hidden" name="q[event_end_date_lteq]" :value="event_end_date_lteq">
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  props: [
    'initialStartDate',
    'initialEndDate',
    'initialCountryId',
    'initialStateId',
    'initialCityId',
    'initialGracedBy',
  ],
  data: function () {
    return {
      country: null,
      state: null,
      city: null,
      graced_by_eq: this.initialGracedBy,
      event_start_date_gteq: this.initialStartDate,
      event_end_date_lteq: this.initialEndDate,
      countryOptions: [],
      stateOptions: [],
      cityOptions: [],
      gracedByOptions: ['Baba ji', 'Ishan ji', 'Subtle presence of Babaji'],
    }
  },
  computed: {
    startDateConfig () {
      return {
        minDate: 'today',
        maxDate: this.event_end_date_lteq,
        altInput: true,
        altFormat: 'F j, Y',
        wrap: true,
      }
    },
    endDateConfig () {
      return {
        minDate: (this.event_start_date_gteq || 'today'),
        altInput: true,
        altFormat: 'F j, Y',
        wrap: true,
      }
    },
    address_country_id_eq () {
      return (this.country || {}).id
    },
    address_state_id_eq () {
      return (this.state || {}).id
    },
    address_city_id_eq () {
      return (this.city || {}).id
    },
  },
  created () {
    var _this = this
    this.$axios.get('/countries.json')
      .then(response => {
        this.countryOptions = response.data

        if (this.initialCountryId) {
          this.country = this.countryOptions.find(country => {
            return country.id == this.initialCountryId
          })

          this.$axios.get(`/countries/${this.initialCountryId}/states.json`)
            .then(response => {
              this.stateOptions = response.data

              if (this.initialStateId)
                this.state = this.stateOptions.find(state => {
                  return state.id == this.initialStateId
                })

                this.$axios.get(`/countries/${this.initialCountryId}/states/${this.initialStateId}/cities.json`)
                  .then(response => {
                    this.cityOptions = response.data

                    if (this.initialCityId)
                      this.city = this.cityOptions.find(city => {
                        return city.id == this.initialCityId
                      })
                  })
            })
        }
      })
  },
  methods: {
    resetStateAndCityOptions () {
      this.state = null
      this.city = null
      this.cityOptions = []
      if (this.address_country_id_eq)
        this.$axios.get(`/countries/${this.address_country_id_eq}/states.json`)
          .then(response => {
            this.stateOptions = response.data
          })
      else
        this.stateOptions = []
    },
    resetCityOptions () {
      this.city = null
      if (this.address_state_id_eq)
        this.$axios.get(`/countries/${this.address_country_id_eq}/states/${this.address_state_id_eq}/cities.json`)
          .then(response => {
            this.cityOptions = response.data
          })
      else
        this.cityOptions = []
    },
    submit () {
      document.getElementById('js-hidden-form').submit()
    }
  }
}
</script>

<style lang="scss">
.md-form.input-group .form-control {
    padding: 11px 15px !important;
}

.md-form input,
.md-form input:focus {
  border: none !important;
  font-size: 14px !important;
  color: #333 !important;
}

.event_filter_box input.vs__search {
  width: 0 !important;
  padding: 12px 14px !important;
  font-size: 14px !important;
}

.event_filter_box .date-input input {
  padding: 11px 15px !important;
  border-radius: 0;
  border: 1px solid #ccc !important;
  font-size: 14px !important;
  font-weight: 500;
  text-align: left;
}

.vs__dropdown-toggle {
  border-radius: 0;
  border: 1px solid #ccc;
  font-size: 14px !important;
  font-weight: 500;
  padding: 0;
  margin: 0;
  -moz-appearance: none;
  -webkit-appearance: none;
}

.vs--open .vs__dropdown-toggle {
  border: 1px solid #ff6a40;
}

.v-select {
  cursor: pointer;
}

.vs__selected {
  margin-left: 8px;
}

.input-group {
  margin-bottom: 0;
}
</style>
