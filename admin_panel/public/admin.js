const dataNode = document.getElementById('dashboard-data');
const data = dataNode ? JSON.parse(dataNode.textContent) : {};

// ── Modal de confirmación (diseño del panel) ─────────────────────────────────
function aevumConfirm({ title = '¿Continuar?', message = '', hint = '', confirmLabel = 'Aceptar', danger = false } = {}) {
  return new Promise((resolve) => {
    const backdrop = document.getElementById('aevumModal');
    if (!backdrop) {
      resolve(window.confirm([message, hint].filter(Boolean).join('\n\n')));
      return;
    }
    const titleEl = document.getElementById('aevumModalTitle');
    const msgEl = document.getElementById('aevumModalMessage');
    const hintEl = document.getElementById('aevumModalHint');
    const btnOk = document.getElementById('aevumModalConfirm');
    const btnCancel = document.getElementById('aevumModalCancel');
    if (titleEl) titleEl.textContent = title;
    if (msgEl) msgEl.textContent = message;
    if (hintEl) {
      hintEl.textContent = hint || '';
      hintEl.style.display = hint ? '' : 'none';
    }
    if (btnOk) {
      btnOk.textContent = confirmLabel;
      btnOk.classList.toggle('danger', Boolean(danger));
    }
    const close = (value) => {
      backdrop.classList.remove('open');
      backdrop.setAttribute('aria-hidden', 'true');
      btnOk?.removeEventListener('click', onOk);
      btnCancel?.removeEventListener('click', onCancel);
      backdrop.removeEventListener('click', onBackdrop);
      document.removeEventListener('keydown', onKey);
      resolve(value);
    };
    const onOk = () => close(true);
    const onCancel = () => close(false);
    const onBackdrop = (e) => { if (e.target === backdrop) close(false); };
    const onKey = (e) => {
      if (e.key === 'Escape') close(false);
      if (e.key === 'Enter') close(true);
    };
    btnOk?.addEventListener('click', onOk);
    btnCancel?.addEventListener('click', onCancel);
    backdrop.addEventListener('click', onBackdrop);
    document.addEventListener('keydown', onKey);
    backdrop.classList.add('open');
    backdrop.setAttribute('aria-hidden', 'false');
    setTimeout(() => btnCancel?.focus(), 0);
  });
}

function getActiveContext() {
  return {
    view: document.querySelector('.nav-btn.active')?.dataset.view || 'dashboard',
    catalog: document.querySelector('.catalog-tab.active')?.dataset.catalog || null,
  };
}

function activateView(view) {
  document.querySelectorAll('.nav-btn').forEach(x => x.classList.toggle('active', x.dataset.view === view));
  document.querySelectorAll('.view').forEach(x => x.classList.toggle('active', x.id === `view-${view}`));
}

function activateCatalogTab(catalog) {
  if (!catalog) return;
  document.querySelectorAll('.catalog-tab').forEach(x => x.classList.toggle('active', x.dataset.catalog === catalog));
  document.querySelectorAll('.catalog-panel').forEach(x => x.classList.toggle('active', x.id === `catalog-${catalog}`));
}

/** Actualiza HTML del servidor sin salir de la vista actual (sin Ctrl+R). */
async function softRefreshKeepContext() {
  const ctx = getActiveContext();
  try {
    const res = await fetch(window.location.pathname + window.location.search, {
      credentials: 'same-origin',
      headers: { Accept: 'text/html' },
    });
    if (!res.ok) throw new Error('No se pudo actualizar la vista');
    const html = await res.text();
    const doc = new DOMParser().parseFromString(html, 'text/html');

    document.querySelectorAll('.catalog-panel').forEach((panel) => {
      const fresh = doc.getElementById(panel.id);
      if (fresh) panel.innerHTML = fresh.innerHTML;
    });

    const sug = document.getElementById('suggestionsList');
    const sugFresh = doc.getElementById('suggestionsList') || doc.querySelector('.suggestions-list');
    if (sug && sugFresh) sug.innerHTML = sugFresh.innerHTML;

    const badge = document.getElementById('pendingSuggestionsCount');
    const badgeFresh = doc.getElementById('pendingSuggestionsCount');
    if (badge && badgeFresh) badge.textContent = badgeFresh.textContent;

    const ver = document.getElementById('catalogVersion');
    const verFresh = doc.getElementById('catalogVersion');
    if (ver && verFresh) ver.textContent = verFresh.textContent;

    rebindCatalogUi();
    bindSuggestionButtons(document);
// Evitar doble enlace al hacer softRefresh
document.querySelectorAll('.crud-form, .delete-record, .edit-record').forEach(el => { el.dataset.bound = '1'; });

    activateView(ctx.view);
    if (ctx.view === 'catalogs') activateCatalogTab(ctx.catalog);
  } catch (err) {
    console.error('[AEVUM] softRefresh', err);
    sessionStorage.setItem('aevum_view', ctx.view);
    if (ctx.catalog) sessionStorage.setItem('aevum_catalog_tab', ctx.catalog);
    location.reload();
  }
}


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

// Crear o actualizar (sin recargar la página).
document.querySelectorAll('.crud-form').forEach(form => {
  form.addEventListener('submit', async event => {
    event.preventDefault();
    if (form.dataset.listening === '1') return;
    const payload = Object.fromEntries(new FormData(form).entries());
    try {
      const id = form.dataset.editId;
      await api(id ? `/api/admin/catalog/${form.dataset.type}/${encodeURIComponent(id)}` : `/api/admin/catalog/${form.dataset.type}`, {
        method: id ? 'PUT' : 'POST',
        body: JSON.stringify(payload),
      });
      delete form.dataset.editId;
      const submit = form.querySelector('button[type="submit"]');
      if (submit && submit.dataset.defaultLabel) submit.textContent = submit.dataset.defaultLabel;
      await softRefreshKeepContext();
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
    const ok = await aevumConfirm({
      title: 'Dar de baja registro',
      message: '¿Seguro que desea dar de baja este registro del catálogo?',
      hint: 'Dejará de aparecer en la app después de sincronizar. Los históricos no se eliminan.',
      confirmLabel: 'Dar de baja',
      danger: true,
    });
    if (!ok) return;
    try {
      await api(`/api/admin/catalog/${button.dataset.type}/${encodeURIComponent(button.dataset.id)}`, {method:'DELETE'});
      await softRefreshKeepContext();
    } catch (error) { alert(error.message); }
  });
});

function bindSuggestionButtons(root = document) {
  root.querySelectorAll('[data-suggestion]').forEach(button => {
    if (button.dataset.bound === '1') return;
    button.dataset.bound = '1';
    button.addEventListener('click', async () => {
      const action = button.dataset.action;
      const row = button.closest('.suggestion-row');
      const name = row?.querySelector('strong')?.textContent?.trim() || 'esta sugerencia';
      const kind = row?.querySelector('.pill')?.textContent?.trim() || 'lengua/idioma';
      if (action === 'reject') {
        const ok = await aevumConfirm({
          title: 'Rechazar sugerencia',
          message: `¿Seguro que desea rechazar añadir «${name}» (${kind}) a la lista de lenguas de la base de datos?`,
          hint: 'Esta acción no se puede deshacer desde el panel.',
          confirmLabel: 'Rechazar',
          danger: true,
        });
        if (!ok) return;
      } else if (action === 'approve') {
        const ok = await aevumConfirm({
          title: 'Aprobar sugerencia',
          message: `¿Confirma aprobar «${name}» y añadirla al catálogo de lenguas de la base de datos?`,
          hint: 'La versión del catálogo se incrementará y la app podrá sincronizar el cambio.',
          confirmLabel: 'Aprobar',
          danger: false,
        });
        if (!ok) return;
      }
      try {
        await api(`/api/admin/suggestions/${button.dataset.suggestion}/${action}`, {method:'POST', body:'{}'});
        if (typeof window.__aevumRefreshSuggestions === 'function') {
          await window.__aevumRefreshSuggestions();
        } else {
          await softRefreshKeepContext();
        }
      } catch (error) { alert(error.message); }
    });
  });
}
bindSuggestionButtons(document);


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
      await softRefreshKeepContext();
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


// ═══════════════════════════════════════════════════════════════════════════════
// Actualización sin recarga + tiempo real + PDF
// ═══════════════════════════════════════════════════════════════════════════════

const chartInstances = {};

function destroyCharts() {
  Object.values(chartInstances).forEach(c => { try { c.destroy(); } catch (_) {} });
  for (const k of Object.keys(chartInstances)) delete chartInstances[k];
}

function renderChartsFromData(payload) {
  destroyCharts();
  const ink = '#27352e';
  const grid = 'rgba(44,66,54,.08)';
  const palette = ['#00923f','#2eaa63','#8ca48d','#a7baa9','#d3d5bd','#7b6f61','#9c8f7d','#667b70','#b0a58f','#718f7e'];
  const bar = (id, rows, horizontal = true) => {
    const el = document.getElementById(id); if (!el) return;
    chartInstances[id] = new Chart(el, {
      type: 'bar',
      data: { labels: (rows || []).map(x => x.label), datasets: [{ data: (rows || []).map(x => x.value), backgroundColor: '#00923f', borderRadius: 5, borderSkipped: false }] },
      options: { indexAxis: horizontal ? 'y' : 'x', responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { beginAtZero: true, grid: { color: grid }, ticks: { color: ink, precision: 0 } }, y: { grid: { display: false }, ticks: { color: ink } } } },
    });
  };
  const doughnut = (id, rows) => {
    const el = document.getElementById(id); if (!el) return;
    chartInstances[id] = new Chart(el, {
      type: 'doughnut',
      data: { labels: (rows || []).map(x => x.label), datasets: [{ data: (rows || []).map(x => x.value), backgroundColor: palette, borderWidth: 2, borderColor: '#fff' }] },
      options: { responsive: true, maintainAspectRatio: false, cutout: '64%', plugins: { legend: { position: 'bottom', labels: { boxWidth: 9, usePointStyle: true, color: ink } } } },
    });
  };
  const line = (id, rows) => {
    const el = document.getElementById(id); if (!el) return;
    chartInstances[id] = new Chart(el, {
      type: 'line',
      data: { labels: (rows || []).map(x => x.label), datasets: [{ data: (rows || []).map(x => x.value), borderColor: '#00923f', backgroundColor: 'rgba(0,146,63,.10)', fill: true, tension: .3, pointRadius: 4 }] },
      options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { grid: { display: false }, ticks: { color: ink } }, y: { beginAtZero: true, grid: { color: grid }, ticks: { color: ink, precision: 0 } } } },
    });
  };
  bar('careerChart', payload.careers, true);
  doughnut('profileChart', payload.profiles);
  line('affinityChart', payload.affinity);
  bar('provenanceChart', payload.provenance, true);
  bar('schoolChart', payload.schools, true);
  doughnut('languageChart', payload.languages);
  doughnut('idiomChart', payload.idioms);
}

function renderEvaluationRows(evaluations) {
  const tbody = document.getElementById('evaluationRows');
  if (!tbody) return;
  if (!(evaluations || []).length) {
    tbody.innerHTML = '<tr><td colspan="9" class="empty">No hay evaluaciones para los filtros seleccionados.</td></tr>';
    return;
  }
  tbody.innerHTML = evaluations.map(row => {
    const fecha = row.completed_at
      ? new Date(row.completed_at).toLocaleDateString('es-MX', { day: '2-digit', month: 'short', year: 'numeric' })
      : '—';
    const open = (row.open_answers || []).length
      ? `<details class="open-answer-details"><summary>Ver ${row.open_answers.length}</summary><div class="open-answer-list">${
          row.open_answers.map(a => `<article><strong>${escapeHtml(a.career_name || '')}</strong><small>${escapeHtml(a.question_text || 'Pregunta complementaria')}</small><p>${escapeHtml(a.answer || '')}</p></article>`).join('')
        }</div></details>`
      : '—';
    return `<tr>
      <td><strong>${escapeHtml(row.municipality_name ?? 'No especificado')}</strong><small>${escapeHtml(row.state_name ?? '')}</small></td>
      <td>${escapeHtml(row.school_name ?? 'No especificada')}</td>
      <td>${escapeHtml(row.lenguas || '—')}</td>
      <td>${escapeHtml(row.idiomas || '—')}</td>
      <td><span class="code">${escapeHtml(row.holland_code || '')}</span></td>
      <td>${escapeHtml(row.top_career_name || '')}</td>
      <td><span class="affinity">${Number(row.top_career_affinity ?? 0).toFixed(1)}%</span></td>
      <td>${fecha}</td>
      <td>${open}</td>
    </tr>`;
  }).join('');
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function updateKpis(totals) {
  const t = totals || {};
  const el = (id) => document.getElementById(id);
  if (el('kpiEvaluations')) el('kpiEvaluations').textContent = t.total_evaluations ?? 0;
  if (el('kpiSchools')) el('kpiSchools').textContent = t.schools ?? 0;
  if (el('kpiProfiles')) el('kpiProfiles').textContent = t.profiles ?? 0;
  if (el('kpiAffinity')) {
    el('kpiAffinity').textContent = t.average_affinity != null ? `${t.average_affinity}%` : '—';
  }
}

function currentFilterQuery() {
  const form = document.getElementById('filterForm');
  if (!form) return '';
  const params = new URLSearchParams(new FormData(form));
  // quitar vacíos
  [...params.keys()].forEach(k => { if (!params.get(k)) params.delete(k); });
  return params.toString();
}

function syncPdfLink() {
  const link = document.getElementById('downloadPdf');
  if (!link) return;
  const q = currentFilterQuery();
  link.href = q ? `/api/admin/report.pdf?${q}` : '/api/admin/report.pdf';
}

async function refreshDashboard(silent = false) {
  const q = currentFilterQuery();
  const url = q ? `/api/dashboard/summary?${q}` : '/api/dashboard/summary';
  try {
    if (!silent) {
      const status = document.getElementById('liveStatus');
      if (status) status.querySelector('span').textContent = 'Actualizando…';
    }
    const res = await fetch(url, { credentials: 'same-origin' });
    if (!res.ok) throw new Error('Error al consultar estadísticas');
    const payload = await res.json();
    updateKpis(payload.totals);
    renderChartsFromData(payload);
    renderEvaluationRows(payload.evaluations);
    syncPdfLink();
    // actualizar history sin reload
    const newUrl = q ? `/?${q}` : '/';
    if (location.search !== (q ? `?${q}` : '') && history.replaceState) {
      history.replaceState(null, '', newUrl);
    }
    const status = document.getElementById('liveStatus');
    if (status) {
      status.querySelector('span').textContent = 'Datos al día';
      status.querySelector('i').style.background = '#4a8b5d';
    }
  } catch (err) {
    console.error(err);
    const status = document.getElementById('liveStatus');
    if (status) {
      status.querySelector('span').textContent = 'Error de actualización';
      status.querySelector('i').style.background = '#a64343';
    }
  }
}

// Interceptar submit de filtros → AJAX
const filterForm = document.getElementById('filterForm');
filterForm?.addEventListener('submit', (e) => {
  e.preventDefault();
  refreshDashboard(false);
});

document.getElementById('clearFilters')?.addEventListener('click', (e) => {
  e.preventDefault();
  filterForm?.querySelectorAll('select, input[type="date"]').forEach(el => { el.value = ''; });
  updateDashboardDependencies();
  refreshDashboard(false);
});

// PDF siempre con filtros actuales
syncPdfLink();
filterForm?.addEventListener('change', syncPdfLink);


function rebindCatalogUi() {
  document.querySelectorAll('.catalog-search').forEach(input => {
    if (input.dataset.bound === '1') return;
    input.dataset.bound = '1';
    input.addEventListener('input', () => {
      const term = input.value.trim().toLocaleLowerCase('es');
      const table = input.closest('.table-card')?.querySelector('tbody');
      table?.querySelectorAll('tr').forEach(row => {
        row.hidden = Boolean(term && !(row.dataset.search ?? row.textContent).toLocaleLowerCase('es').includes(term));
      });
    });
  });
  document.querySelectorAll('.dependent-form').forEach(form => {
    if (form.dataset.boundDep === '1') return;
    form.dataset.boundDep = '1';
    const state = form.querySelector('.state-select');
    const municipality = form.querySelector('.municipality-select');
    const update = () => filterOptions(municipality, 'state', state?.value ?? '');
    state?.addEventListener('change', () => { if (municipality) municipality.value = ''; update(); });
    update();
  });
  document.querySelectorAll('.crud-form').forEach(form => {
    if (form.dataset.bound === '1') return;
    form.dataset.bound = '1';
    form.addEventListener('submit', async event => {
      event.preventDefault();
      const payload = Object.fromEntries(new FormData(form).entries());
      try {
        const id = form.dataset.editId;
        await api(id ? `/api/admin/catalog/${form.dataset.type}/${encodeURIComponent(id)}` : `/api/admin/catalog/${form.dataset.type}`, {
          method: id ? 'PUT' : 'POST',
          body: JSON.stringify(payload),
        });
        delete form.dataset.editId;
        await softRefreshKeepContext();
      } catch (error) {
        alert(error.message);
      }
    });
  });
  document.querySelectorAll('.edit-record').forEach(button => {
    if (button.dataset.bound === '1') return;
    button.dataset.bound = '1';
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
      if (submit) {
        if (!submit.dataset.defaultLabel) submit.dataset.defaultLabel = submit.textContent;
        submit.textContent = 'Guardar cambios';
      }
      form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
  document.querySelectorAll('.delete-record').forEach(button => {
    if (button.dataset.bound === '1') return;
    button.dataset.bound = '1';
    button.addEventListener('click', async () => {
      const ok = await aevumConfirm({
        title: 'Dar de baja registro',
        message: '¿Seguro que desea dar de baja este registro del catálogo?',
        hint: 'Dejará de aparecer en la app después de sincronizar. Los históricos no se eliminan.',
        confirmLabel: 'Dar de baja',
        danger: true,
      });
      if (!ok) return;
      try {
        await api(`/api/admin/catalog/${button.dataset.type}/${encodeURIComponent(button.dataset.id)}`, { method: 'DELETE' });
        await softRefreshKeepContext();
      } catch (error) { alert(error.message); }
    });
  });
}

// Socket.IO — tiempo real completo + polling de respaldo
(function initRealtime() {
  const status = document.getElementById('liveStatus');
  let socketConnected = false;
  let lastEvalCount = null;
  let lastCatalogVersion = null;
  let pollTimer = null;

  function setStatus(label, color) {
    if (!status) return;
    const span = status.querySelector('span');
    const dot = status.querySelector('i');
    if (span) span.textContent = label;
    if (dot) dot.style.background = color;
  }
  function updateCatalogVersion(version) {
    if (version == null) return;
    lastCatalogVersion = Number(version);
    const el = document.getElementById('catalogVersion');
    if (el) el.textContent = `#${lastCatalogVersion}`;
  }
  function updatePendingBadge(count) {
    const el = document.getElementById('pendingSuggestionsCount');
    if (el) el.textContent = String(count ?? 0);
  }
  function showLiveToast(title, detail) {
    let toast = document.getElementById('liveToast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'liveToast';
      toast.style.cssText = 'position:fixed;right:20px;bottom:20px;z-index:9999;background:#123a2a;color:#fff;padding:12px 16px;border-radius:10px;font-size:13px;box-shadow:0 8px 24px rgba(0,0,0,.18);max-width:320px;opacity:0;transition:opacity .25s';
      document.body.appendChild(toast);
    }
    toast.innerHTML = `<strong>${title}</strong>${detail ? `<br>${detail}` : ''}`;
    toast.style.opacity = '1';
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => { toast.style.opacity = '0'; }, 4500);
  }

  async function refreshSuggestions() {
    try {
      const res = await fetch('/api/admin/suggestions', { credentials: 'same-origin' });
      if (!res.ok) return;
      const payload = await res.json();
      const list = document.getElementById('suggestionsList');
      if (!list) return;
      const rows = payload.suggestions || [];
      updatePendingBadge(rows.filter(r => r.status === 'pending').length);
      if (!rows.length) {
        list.innerHTML = '<p class="empty">No hay sugerencias todavía.</p>';
        return;
      }
      list.innerHTML = rows.map(row => {
        const fecha = row.created_at ? new Date(row.created_at).toLocaleString('es-MX') : '';
        const actions = row.status === 'pending'
          ? `<button class="small-btn approve" data-suggestion="${row.id}" data-action="approve">Aprobar</button><button class="small-btn danger" data-suggestion="${row.id}" data-action="reject">Rechazar</button>`
          : '';
        return `<div class="suggestion-row"><div><span class="pill">${escapeHtml(row.kind || '')}</span><strong>${escapeHtml(row.name || '')}</strong><small>${escapeHtml(fecha)}</small></div><div><span class="status-label ${escapeHtml(row.status || '')}">${escapeHtml(row.status || '')}</span>${actions}</div></div>`;
      }).join('');
      bindSuggestionButtons(list);
    } catch (err) {
      console.error('[AEVUM] refreshSuggestions', err);
    }
  }
  window.__aevumRefreshSuggestions = refreshSuggestions;

  async function pollLiveState() {
    try {
      const res = await fetch('/api/admin/live-state', { credentials: 'same-origin' });
      if (!res.ok) return;
      const state = await res.json();
      if (state.catalogVersion != null) {
        if (lastCatalogVersion != null && Number(state.catalogVersion) !== lastCatalogVersion) {
          showLiveToast('Catálogo actualizado', `Versión #${state.catalogVersion}`);
        }
        updateCatalogVersion(state.catalogVersion);
      }
      if (state.pendingSuggestions != null) updatePendingBadge(state.pendingSuggestions);
      const total = state.totals?.total_evaluations;
      if (total != null) {
        if (lastEvalCount != null && Number(total) > lastEvalCount) {
          if (typeof refreshDashboard === 'function') refreshDashboard(true);
          showLiveToast('Nuevas evaluaciones', `Total: ${total}`);
        }
        lastEvalCount = Number(total);
      }
      if (!socketConnected) setStatus('Datos al día (polling)', '#c9a227');
    } catch (err) {
      if (!socketConnected) setStatus('Sin conexión en vivo', '#a64343');
    }
  }
  function startPolling(ms = 20000) {
    if (pollTimer) clearInterval(pollTimer);
    pollTimer = setInterval(pollLiveState, ms);
    setTimeout(pollLiveState, 1500);
  }

  if (typeof io === 'undefined') {
    setStatus('Polling activo', '#c9a227');
    startPolling(15000);
    return;
  }
  const socket = io({
    path: '/socket.io',
    withCredentials: true,
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: Infinity,
    reconnectionDelay: 1000,
  });
  socket.on('connect', () => { socketConnected = true; setStatus('Tiempo real activo', '#4a8b5d'); });
  socket.on('disconnect', () => { socketConnected = false; setStatus('Reconectando…', '#c9a227'); });
  socket.on('connect_error', () => { socketConnected = false; setStatus('Socket no disponible — polling', '#c9a227'); });
  socket.on('connected', (msg) => console.log('[AEVUM]', msg?.message || 'conectado'));
  socket.on('new-evaluation', (payload) => {
    const career = payload?.top_career_name || 'Nueva evaluación';
    const school = payload?.school_name ? ` · ${payload.school_name}` : '';
    showLiveToast('Nueva evaluación', `${career}${school}`);
    if (typeof refreshDashboard === 'function') refreshDashboard(true);
    if (lastEvalCount != null) lastEvalCount += 1;
  });
  socket.on('catalog-updated', () => { showLiveToast('Catálogo actualizado', ''); pollLiveState(); });
  socket.on('suggestion-created', (payload) => {
    showLiveToast('Nueva sugerencia', `${payload?.kind || ''} · ${payload?.name || ''}`);
    refreshSuggestions();
  });
  socket.on('suggestion-updated', (payload) => {
    const action = payload?.action === 'approve' ? 'aprobada' : 'rechazada';
    showLiveToast(`Sugerencia ${action}`, payload?.name || '');
    refreshSuggestions();
    if (payload?.catalogChanged) pollLiveState();
  });
  startPolling(20000);
})();

// Restaurar vista si un softRefresh debió caer a reload
(function restoreView() {
  const v = sessionStorage.getItem('aevum_view');
  const c = sessionStorage.getItem('aevum_catalog_tab');
  if (v) { activateView(v); sessionStorage.removeItem('aevum_view'); }
  if (c) { activateCatalogTab(c); sessionStorage.removeItem('aevum_catalog_tab'); }
})();

// Re-render inicial guardando instancias (para poder destruirlas después)
if (typeof Chart !== 'undefined' && data && Object.keys(data).length) {
  // Los charts iniciales ya se crearon arriba; registramos referencias si existen
  ['careerChart','profileChart','affinityChart','provenanceChart','schoolChart','languageChart','idiomChart'].forEach(id => {
    const el = document.getElementById(id);
    if (el && typeof Chart.getChart === 'function') {
      const existing = Chart.getChart(el);
      if (existing) chartInstances[id] = existing;
    }
  });
}