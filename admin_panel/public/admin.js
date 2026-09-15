const dataNode = document.getElementById('dashboard-data');
const data = dataNode ? JSON.parse(dataNode.textContent) : {};

// Navegación principal.
document.querySelectorAll('.nav-btn').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.nav-btn').forEach(x => x.classList.remove('active'));
    document.querySelectorAll('.view').forEach(x => x.classList.remove('active'));
    button.classList.add('active');
    document.getElementById(`view-${button.dataset.view}`)?.classList.add('active');
  });
});

// Pestañas CRUD.
document.querySelectorAll('.catalog-tab').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.catalog-tab').forEach(x => x.classList.remove('active'));
    document.querySelectorAll('.catalog-panel').forEach(x => x.classList.remove('active'));
    button.classList.add('active');
    document.getElementById(`catalog-${button.dataset.catalog}`)?.classList.add('active');
  });
});

function filterOptions(select, attr, value) {
  if (!select) return;
  [...select.options].forEach((option, index) => {
    if (index === 0) return;
    const relation = option.dataset[attr] ?? '';
    option.hidden = Boolean(value && relation && relation !== value);
  });
  if (select.selectedOptions[0]?.hidden) select.value = '';
}

const filterState = document.getElementById('filterState');
const filterMunicipality = document.getElementById('filterMunicipality');
const filterSchool = document.getElementById('filterSchool');
function updateDashboardDependencies() {
  filterOptions(filterMunicipality, 'state', filterState?.value ?? '');
  filterOptions(filterSchool, 'municipality', filterMunicipality?.value ?? '');
}
filterState?.addEventListener('change', () => { if(filterMunicipality) filterMunicipality.value=''; if(filterSchool) filterSchool.value=''; updateDashboardDependencies(); });
filterMunicipality?.addEventListener('change', () => { if(filterSchool) filterSchool.value=''; updateDashboardDependencies(); });
updateDashboardDependencies();

// Dependencia Estado > Municipio en alta/edición de escuelas.
document.querySelectorAll('.dependent-form').forEach(form => {
  const state = form.querySelector('.state-select');
  const municipality = form.querySelector('.municipality-select');
  const update = () => filterOptions(municipality, 'state', state?.value ?? '');
  state?.addEventListener('change', () => { municipality.value=''; update(); });
  update();
});

// Búsquedas locales dentro de cada catálogo.
document.querySelectorAll('.catalog-search').forEach(input => {
  input.addEventListener('input', () => {
    const term = input.value.trim().toLocaleLowerCase('es');
    const table = input.closest('.table-card')?.querySelector('tbody');
    table?.querySelectorAll('tr').forEach(row => {
      row.hidden = Boolean(term && !(row.dataset.search ?? row.textContent).toLocaleLowerCase('es').includes(term));
    });
  });
});

const evalSearch = document.getElementById('tableSearch');
evalSearch?.addEventListener('input', () => {
  const term = evalSearch.value.trim().toLocaleLowerCase('es');
  document.querySelectorAll('#evaluationRows tr').forEach(row => {
    row.hidden = Boolean(term && !row.textContent.toLocaleLowerCase('es').includes(term));
  });
});

async function api(url, options = {}) {
  const response = await fetch(url, { headers: {'Content-Type':'application/json'}, ...options });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || 'No fue posible realizar el cambio');
  return body;
}

// Crear o actualizar.
document.querySelectorAll('.crud-form').forEach(form => {
  form.addEventListener('submit', async event => {
    event.preventDefault();
    const payload = Object.fromEntries(new FormData(form).entries());
    try {
      const id = form.dataset.editId;
      await api(id ? `/api/admin/catalog/${form.dataset.type}/${encodeURIComponent(id)}` : `/api/admin/catalog/${form.dataset.type}`, {
        method: id ? 'PUT' : 'POST',
        body: JSON.stringify(payload),
      });
      location.reload();
    } catch (error) {
      alert(error.message);
    }
  });
});

// Pasar un registro a su formulario de edición.
document.querySelectorAll('.edit-record').forEach(button => {
  button.addEventListener('click', () => {
    const type = button.dataset.type;
    const form = document.querySelector(`.crud-form[data-type="${type}"]`);
    if (!form) return;
    const record = JSON.parse(button.dataset.record);
    form.dataset.editId = button.dataset.id;
    [...form.elements].forEach(field => {
      if (!field.name || field.type === 'submit') return;
      if (record[field.name] !== undefined && record[field.name] !== null) field.value = record[field.name];
      if (field.name === 'active') field.value = '1';
      if (field.name.startsWith('weight_') && record.weights) field.value = record.weights[field.name.slice(-1)] ?? field.value;
    });
    if (type === 'schools') {
      const municipality = form.querySelector('.municipality-select');
      filterOptions(municipality, 'state', form.querySelector('.state-select')?.value ?? '');
      if (record.municipality_id) municipality.value = record.municipality_id;
    }
    const submit = form.querySelector('button[type="submit"]');
    if (submit) submit.textContent = 'Guardar cambios';
    form.scrollIntoView({behavior:'smooth', block:'start'});
  });
});

document.querySelectorAll('.delete-record').forEach(button => {
  button.addEventListener('click', async () => {
    if (!confirm('¿Dar de baja este registro? Dejará de aparecer en la app después de sincronizar.')) return;
    try {
      await api(`/api/admin/catalog/${button.dataset.type}/${encodeURIComponent(button.dataset.id)}`, {method:'DELETE'});
      location.reload();
    } catch (error) { alert(error.message); }
  });
});

document.querySelectorAll('[data-suggestion]').forEach(button => {
  button.addEventListener('click', async () => {
    try {
      await api(`/api/admin/suggestions/${button.dataset.suggestion}/${button.dataset.action}`, {method:'POST', body:'{}'});
      location.reload();
    } catch (error) { alert(error.message); }
  });
});


// Pregunta complementaria única por departamento.
document.querySelectorAll('.department-question-form').forEach(form => {
  form.addEventListener('submit', async event => {
    event.preventDefault();
    const department = form.dataset.department;
    const questionText = form.querySelector('[name="question_text"]')?.value.trim() ?? '';
    if (!department || !questionText) return;
    const button = form.querySelector('button[type="submit"]');
    const previous = button?.textContent;
    if (button) {
      button.disabled = true;
      button.textContent = 'Guardando…';
    }
    try {
      await api(`/api/admin/department-questions/${encodeURIComponent(department)}`, {
        method: 'PUT',
        body: JSON.stringify({question_text: questionText}),
      });
      if (button) button.textContent = 'Guardado ✓';
      setTimeout(() => location.reload(), 500);
    } catch (error) {
      alert(error.message);
      if (button) {
        button.disabled = false;
        button.textContent = previous || 'Guardar pregunta';
      }
    }
  });
});

// Gráficas del tablero.
if (typeof Chart !== 'undefined') {
  const ink = '#33423a';
  const grid = 'rgba(44,66,54,.08)';
  const palette = ['#00923f','#2eaa63','#8ca48d','#a7baa9','#d3d5bd','#7b6f61','#9c8f7d','#667b70','#b0a58f','#718f7e'];
  const bar = (id, rows, horizontal=true) => {
    const el=document.getElementById(id); if(!el)return;
    new Chart(el,{type:'bar',data:{labels:(rows||[]).map(x=>x.label),datasets:[{data:(rows||[]).map(x=>x.value),backgroundColor:'#00923f',borderRadius:5,borderSkipped:false}]},options:{indexAxis:horizontal?'y':'x',responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,grid:{color:grid},ticks:{color:ink,precision:0}},y:{grid:{display:false},ticks:{color:ink}}}}});
  };
  const doughnut = (id, rows) => {
    const el=document.getElementById(id); if(!el)return;
    new Chart(el,{type:'doughnut',data:{labels:(rows||[]).map(x=>x.label),datasets:[{data:(rows||[]).map(x=>x.value),backgroundColor:palette,borderWidth:2,borderColor:'#fff'}]},options:{responsive:true,maintainAspectRatio:false,cutout:'64%',plugins:{legend:{position:'bottom',labels:{boxWidth:9,usePointStyle:true,color:ink}}}}});
  };
  const line = (id, rows) => {
    const el=document.getElementById(id); if(!el)return;
    new Chart(el,{type:'line',data:{labels:(rows||[]).map(x=>x.label),datasets:[{data:(rows||[]).map(x=>x.value),borderColor:'#00923f',backgroundColor:'rgba(0,146,63,.10)',fill:true,tension:.3,pointRadius:4}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{grid:{display:false},ticks:{color:ink}},y:{beginAtZero:true,grid:{color:grid},ticks:{color:ink,precision:0}}}}});
  };
  bar('careerChart',data.careers,true); doughnut('profileChart',data.profiles); line('affinityChart',data.affinity);
  bar('provenanceChart',data.provenance,true); bar('schoolChart',data.schools,true); doughnut('languageChart',data.languages); doughnut('idiomChart',data.idioms);
}


// Vista previa RIASEC de carreras.
const careerForm = document.querySelector('.career-form');
if (careerForm) {
  const dims = ['R','I','A','S','E','C'];
  const inputs = dims.map(d => careerForm.querySelector(`[name="weight_${d}"]`));
  const codeNode = document.getElementById('careerProfileCode');
  let radar;
  const refreshCareerProfile = () => {
    const values = Object.fromEntries(dims.map((d,i)=>[d, Math.max(0,Math.min(10,Number(inputs[i]?.value||0)))]));
    const sorted=[...dims].sort((a,b)=>values[b]-values[a] || dims.indexOf(a)-dims.indexOf(b));
    if(codeNode) codeNode.textContent=sorted.slice(0,3).join('');
    const canvas=document.getElementById('careerProfileChart');
    if(canvas && typeof Chart!=='undefined') {
      if(!radar) radar=new Chart(canvas,{type:'radar',data:{labels:dims,datasets:[{label:'Perfil RIASEC',data:dims.map(d=>values[d]),borderColor:'#00923f',backgroundColor:'rgba(0,146,63,.12)',pointBackgroundColor:'#00923f'}]},options:{responsive:true,maintainAspectRatio:false,scales:{r:{beginAtZero:true,max:10,ticks:{stepSize:2}}},plugins:{legend:{display:false}}}});
      else { radar.data.datasets[0].data=dims.map(d=>values[d]); radar.update(); }
    }
  };
  inputs.forEach(x=>x?.addEventListener('input',refreshCareerProfile));
  document.querySelectorAll('.edit-record[data-type="careers"]').forEach(btn=>btn.addEventListener('click',()=>setTimeout(refreshCareerProfile,0)));
  refreshCareerProfile();
}
