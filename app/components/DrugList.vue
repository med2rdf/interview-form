<script setup>
const props = defineProps({
  drugList: {
    type: Array,
    required: true,
  },
  selectedDrugs: {
    type: Object,
    required: true,
  }
})
const { drugList, selectedDrugs } = toRefs(props)
</script>

<template>
  <div>
    <ul v-if="drugList" class="drugList">
      <li v-for="drug in drugList" :id="drug.id" class="drugList_drug" @click="$emit('clickDrugName', drug)">
        <span class="drugList_checkbox"
          :class="{ 'drugList_checkbox-selected': selectedDrugs.some(selectedDrug => selectedDrug.if_id === drug.if_id) }"></span>
        <div>
          <p class="drugList_name">{{ drug.drug_name }}</p>
          <p class="drugList_synonyms">{{ drug.synonyms?.map(synonym => synonym.value).join(',') }}</p>
          <p class="drugList_therapeutiClassifications">{{ drug.therapeutic_classifications }}</p>
        </div>
      </li>
    </ul>
  </div>
</template>

<style lang="scss" scoped>
.drugList {
  margin-top: 30px;
  height: calc(100vh - 90px);
  overflow: auto;
  min-width: 244px;

  &_checkbox {
    width: 14px;
    min-width: 14px;
    height: 14px;
    border-radius: 8px;
    margin-right: 6px;
    border: 1px solid #ffffff;

    &-selected {
      background-color: #ffffff;
      position: relative;

      &::after {
        content: '';
        position: absolute;
        top: 10%;
        left: 30%;
        width: 3px;
        height: 6px;
        display: inline-blockck;
        border-bottom: 3px solid $main_color;
        border-right: 3px solid $main_color;
        transform: rotate(45deg);
      }
    }
  }

  &_drug {
    margin-bottom: 16px;
    cursor: pointer;
    display: flex;
  }

  &_name {
    font-size: 14px;
  }

  &_synonyms,
  &_therapeutiClassifications {
    font-size: 11px;
    margin-top: 4px;
    color: #bfd0de;
  }
}
</style>