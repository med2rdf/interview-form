<script>
import { formatContent } from './TableIndex.vue';
</script>
<script setup>
const props = defineProps({
  childContent: {
    type: Object,
    required: true,
  },
  anotherTab: {
    type: String,
    required: true,
  }
})
const { childContent, anotherTab } = toRefs(props)

const config = useRuntimeConfig()

const getRefData = async (ref) => {
  const data = await fetch(`${config.public.API_URL}/interview_form_${anotherTab.value}_section?${anotherTab.value}_id=${ref[`${anotherTab.value}_id`]}&section_id=${ref[`${anotherTab.value}_section_id`]}`)
  const refData = await data.json()
  ref[`${anotherTab.value}_section_body`] = refData.value_list.length > 0 ? formatContent(refData.value_list) : 'データがありません'
}
</script>

<template>
  <div class="tableIndex_body" v-html="childContent.targetContent" @click.stop></div>
  <div v-if="childContent.refData" @click.stop>
    <div v-for="ref in childContent.refData" class="tableIndex_ref" :class="`tableIndex_ref-${anotherTab}`">
      <p class="tableIndex_refTitle" @click="getRefData(ref)">
        {{ ref[`${anotherTab}_section_no`] }} {{ ref[`${anotherTab}_section_name`] }}</p>
      <div v-html="ref[`${anotherTab}_section_body`]" class="tableIndex_refBody"
        :class="{ 'tableIndex_refBody-open': !!ref[`${anotherTab}_section_body`] }"></div>
    </div>
  </div>
</template>

<style lang="scss">
.tableIndex {
  &_body {
    margin-top: 8px;
    font-weight: normal;
    line-height: 1.5;
  }

  &_label {
    margin-right: 4px;
    font-weight: bold;

    &:after {
      content: ':';
      margin-right: 2px;
    }
  }

  &_table {
    margin: 10px 0;

    th,
    td {
      border: 1px solid #000000;
      padding: 4px 8px;
    }
  }

  &_ref {
    border-radius: 5px;
    padding: 12px 18px;
    margin: 8px 0;
    font-weight: normal;

    .tableIndex_refTitle {
      text-decoration: underline;
      display: flex;
      align-items: center;

      &:before {
        content: '';
        width: 16px;
        height: 16px;
        margin-right: 8px;
        background-size: contain;
        display: block;
      }
    }

    &-pi {
      background-color: $pi_pale_color;

      .tableIndex_refTitle:before {
        background-image: url('assets/images/icon-PI.png');
      }
    }

    &-if {
      background-color: $if_pale_color;

      .tableIndex_refTitle:before {
        background-image: url('assets/images/icon-IF.png');
      }
    }
  }

  &_refBody {
    font-size: 13px;
    line-height: 1.2;

    &-open {
      margin-top: 8px;
    }
  }
}
</style>
