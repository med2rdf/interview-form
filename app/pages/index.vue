<script setup>
import DrugDetail from '~/components/DrugDetail.vue';

const config = useRuntimeConfig()
const drugList = ref(null)
const originalDrugList = ref(null)
const letters = ref([])
onMounted(async () => {
  const data = await fetch(`${config.public.API_URL}/interview_form_drug_names`)
  drugList.value = await data.json()
  letters.value = ['ア', 'カ', 'サ', 'タ', 'ナ', 'ハ', 'マ', 'ヤ', 'ラ', 'ワ']
  const usedIds = new Set();
  drugList.value = drugList.value.map(drug => {
    const firstChar = drug.drug_name.charAt(0);
    if (letters.value.includes(firstChar) && !usedIds.has(firstChar)) {
      usedIds.add(firstChar);
      drug.id = firstChar
    }
    return drug
  })
  originalDrugList.value = [...drugList.value]
})


const selectedDrugs = ref([])
const toggleDisplayedDrug = drug => {
  if (selectedDrugs.value.some(selectedDrug => selectedDrug.if_id === drug.if_id)) {
    selectedDrugs.value = selectedDrugs.value.filter(selectedDrug => selectedDrug.if_id !== drug.if_id)
    return
  }
  selectedDrugs.value.unshift(drug)
}

const isSideBarOpen = ref(true)
const searchTargets = ref([
  {
    label: '薬剤名',
    key: 'drug_name',
    selected: true
  },
  {
    label: '一般名',
    key: 'synonyms',
    selected: false
  },
  {
    label: '薬効分類',
    key: 'therapeutic_classifications',
    selected: false
  }
])
const selectedSearchTarget = computed(() => searchTargets.value.find(target => target.selected))
const selectTarget = key => {
  searchTargets.value.forEach(target => {
    if (target.key === key) {
      target.selected = true
    } else {
      target.selected = false
    }
    isPulldownShown.value = false
  })
}
const isPulldownShown = ref(false)

const textSearchInput = ref()
const filterDisplayedDrug = () => {
  drugList.value = originalDrugList.value.filter(drug => {
    if (Array.isArray(drug[selectedSearchTarget.value.key])) {
      return drug[selectedSearchTarget.value.key].some(val => val.value?.includes(textSearchInput.value))
    } else {
      return drug[selectedSearchTarget.value.key]?.includes(textSearchInput.value)
    }
  })
}

const isSummaryOpen = ref(false)

const jumpToTargetIndex = letter => {
  const targetEl = document.querySelector(`#${letter}`)
  targetEl?.scrollIntoView({ behavior: "smooth" });
}
</script>

<template>
  <div v-if="drugList" class="wholeWrapper">
    <div v-if="selectedDrugs.length > 0" class="toggleButton" :class="{ 'toggleButton-close': !isSideBarOpen }"
      @click="isSideBarOpen = !isSideBarOpen">
    </div>
    <aside class="sideBar" :class="{ 'sideBar-close': !isSideBarOpen, 'sideBar-full': selectedDrugs.length < 1 }">
      <img src="~assets/images/logo.png" alt="Interview Form Viewer" class="sideBar_logo">
      <DrugList :drug-list="drugList" :selected-drugs="selectedDrugs" @clickDrugName="toggleDisplayedDrug" />
    </aside>
    <main class="mainContent"
      :class="{ 'mainContent-full': !isSideBarOpen, 'mainContent-hide': selectedDrugs.length < 1 }">
      <form class="formWrapper" :class="{ 'formWrapper-full': selectedDrugs.length < 1 }">
        <div class="formWrapper_searchTarget" @click="isPulldownShown = !isPulldownShown">{{ selectedSearchTarget.label
          }}</div>
        <div v-if="isPulldownShown" class="formWrapper_searchTargetPulldown">
          <p v-for="target in searchTargets" :key="target.key" class="formWrapper_searchTargetLabel" @click="
    selectTarget(target.key)">{{ target.label }}</p>
        </div>
        <input type="text" class="formWrapper_input" v-model="textSearchInput" @input="filterDisplayedDrug">
      </form>
      <div class="drugDetailList">
        <DrugDetail v-for="drug in selectedDrugs" :key="drug.if_id" :drug="drug" class="drugDetailList_card"
          :class="{ 'drugDetailList_card-single': selectedDrugs.length === 1 }" @close-drug="toggleDisplayedDrug" />
      </div>
      <div v-if="selectedDrugs.length > 0" class="selectedDrugsSummary">
        <div class="selectedDrugsSummary_nameList" :class="{ 'selectedDrugsSummary_nameList-full': !isSideBarOpen }">
          <p v-for="selectedDrug in selectedDrugs" :key="selectedDrug.if_id" class="selectedDrugsSummary_name">
            {{ selectedDrug.drug_name }}
            <span class="selectedDrugsSummary_close" @click="toggleDisplayedDrug(selectedDrug)">×</span>
          </p>
        </div>
        <div class="selectedDrugsSummary_menu" @click="isSummaryOpen = !isSummaryOpen">
          <span class="selectedDrugsSummary_menuLine"></span>
          <span class="selectedDrugsSummary_menuLine"></span>
          <span class="selectedDrugsSummary_menuLine"></span>
        </div>
        <div v-if="isSummaryOpen" class="selectedDrugsSummary_window">
          <p v-for="selectedDrug in selectedDrugs" :key="selectedDrug.if_id" class="selectedDrugsSummary_windowName">
            {{ selectedDrug.drug_name }}
            <span class="selectedDrugsSummary_windowNameClose" @click="toggleDisplayedDrug(selectedDrug)">×</span>
          </p>
        </div>
      </div>
      <div v-else class="lettersIndex">
        <template v-for="(letter, index) in letters">
          <span :href="`#${letter}`" class="lettersIndex_letter" @click="jumpToTargetIndex(letter)">{{ letter }}</span>
          <span v-if="index !== letters.length - 1" class="lettersIndex_point">・</span>
        </template>
      </div>
    </main>
  </div>
</template>


<style lang="scss" scoped>
.wholeWrapper {
  position: relative;
  display: flex;
}

.sideBar {
  width: 244px;
  min-width: 244px;
  padding: 26px 0 0 20px;
  border-right: 1px solid #ffffff;
  position: relative;
  overflow: hidden;

  &-close {
    width: 0;
    min-width: 0;
  }

  &-full {
    width: 100%;
    border-right: 0;
  }

  &_logo {
    width: 182px;
    margin: 0 auto;
  }
}

.mainContent {
  padding: 22px 22px 0;
  width: calc(100vw - 265px);
  box-sizing: border-box;

  &-full {
    width: calc(100vw - 20px);
  }

  &-hide {
    padding-right: 0;
    padding-left: 0;
    width: 0;
  }
}

.formWrapper {
  margin-bottom: 20px;
  position: relative;
  color: $main_color;
  font-size: 14px;
  font-weight: bold;

  &_searchTarget {
    position: absolute;
    top: 0;
    left: 0;
    width: 110px;
    box-sizing: border-box;
    height: 32px;
    border-radius: 20px 0 0 20px;
    border-right: 1px solid $main_color;
    background-color: #e5f3f6;
    z-index: 10;
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 0 22px;

    &::after {
      content: "";
      display: inline-block;
      border: 5px solid transparent;
      border-top: 5px solid #2e4d66;
      position: absolute;
      top: 13px;
      right: 12px;
    }
  }

  &_searchTargetPulldown {
    position: absolute;
    top: 34px;
    left: 0;
    width: 110px;
    border-radius: 10px;
    background-color: #e5f3f6;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .5);
    padding: 8px 22px;
    box-sizing: border-box;
    z-index: 10;
  }

  &_searchTargetLabel {
    cursor: pointer;
    margin: 18px 0;
  }

  &_input {
    width: 100%;
    height: 32px;
    border-radius: 20px;
    border: 0;
    box-sizing: border-box;
    padding-left: 120px;

  }

  &-full {
    position: absolute;
    width: calc(100% - 310px);
    right: 24px;
  }
}

.drugDetailList {
  display: flex;
  overflow: auto;
  max-height: calc(100vh - 112px);

  &_card {
    width: 50%;
    min-width: 510px;

    &-single {
      width: 100%;
    }

    &+& {
      margin-left: 14px;
    }
  }
}

.toggleButton {
  position: absolute;
  top: 50px;
  left: 250px;
  width: 32px;
  height: 32px;
  border-radius: 20px;
  background-color: #ffffff;
  cursor: pointer;
  z-index: 10;

  &::after {
    content: '';
    position: absolute;
    top: 34%;
    left: 40%;
    width: 6px;
    height: 6px;
    display: inline-block;
    border-top: 3px solid $main_color;
    border-left: 3px solid $main_color;
    transform: rotate(-45deg);
  }

  &-close {
    left: 5px;

    &::after {
      left: 33%;
      transform: rotate(135deg);
    }
  }
}

.selectedDrugsSummary {
  height: 40px;
  position: absolute;
  bottom: 0;

  &_nameList {
    width: calc(100vw - 310px);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;

    &-full {
      width: calc(100vw - 66px);

    }
  }

  &_name {
    font-size: 12px;
    display: inline-block;
    padding: 15px 0;

    &+& {
      &::before {
        content: '/';
        margin: 0 16px;
      }
    }
  }

  &_close {
    font-size: 14px;
    margin-left: 8px;
    cursor: pointer;
  }

  &_menu {
    display: flex;
    flex-direction: column;
    position: absolute;
    right: 0;
    bottom: 11px;
  }

  &_menuLine {
    width: 16px;
    border-top: 2px solid #ffffff;
    display: inline-block;
    cursor: pointer;

    &+& {
      margin-top: 3px;
    }
  }

  &_window {
    position: absolute;
    bottom: calc(100% - 6px);
    right: -10px;
    border-radius: 10px;
    background-color: #ffffff;
    box-shadow: 0 2px 6px rgba(0, 0, 0, .5);
    padding: 14px 22px;
    box-sizing: border-box;
    z-index: 10;
  }

  &_windowName {
    color: #333;
    font-size: 12px;
    line-height: 2.5;
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-width: 240px;
  }

  &_windowNameClose {
    cursor: pointer;
  }
}

.lettersIndex {
  writing-mode: vertical-rl;
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  white-space: nowrap;
  cursor: pointer;

  &_letter {
    color: #ffffff;
  }

  &_point {
    margin: 10px 0;
  }
}
</style>