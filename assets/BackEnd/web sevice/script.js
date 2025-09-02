const BASE_URL = 'https://isinanej.pythonanywhere.com/db';

async function postData(url = '', data = {}) {
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });
    return response.json();
}

// Function to handle Excel file upload
async function uploadExcel(file) {
    const formData = new FormData();
    formData.append('file', file);

    try {
        const response = await fetch(`${BASE_URL}/import_excel`, {
            method: 'POST',
            body: formData
        });
        const result = await response.json();
        
        const statusDiv = document.getElementById('import-status');
        if (response.ok) {
            statusDiv.innerHTML = `<p class="success">${result.message}</p>`;
        } else {
            statusDiv.innerHTML = `<p class="error">Error: ${result.error}</p>`;
        }
    } catch (error) {
        document.getElementById('import-status').innerHTML = 
            `<p class="error">Error uploading file: ${error.message}</p>`;
    }
}

async function fetchTables() {
    const response = await fetch(`${BASE_URL}/list_tables`);
    const tables = await response.json();
    const tableRows = document.getElementById('table-rows');
    tableRows.innerHTML = '';

    if (Array.isArray(tables)) {
        tables.forEach(table => {
            const row = document.createElement('tr');

            const nameCell = document.createElement('td');
            nameCell.textContent = table;
            row.appendChild(nameCell);

            const actionsCell = document.createElement('td');

            const editButton = document.createElement('button');
            editButton.textContent = 'Edit';
            editButton.addEventListener('click', () => editTable(table));
            actionsCell.appendChild(editButton);

            const deleteButton = document.createElement('button');
            deleteButton.textContent = 'Delete';
            deleteButton.addEventListener('click', () => deleteTable(table));
            actionsCell.appendChild(deleteButton);

            row.appendChild(actionsCell);
            tableRows.appendChild(row);
        });
    } else {
        const row = document.createElement('tr');
        const errorCell = document.createElement('td');
        errorCell.colSpan = 2;
        errorCell.textContent = 'Error fetching tables';
        row.appendChild(errorCell);
        tableRows.appendChild(row);
    }
}

async function deleteTable(tableName) {
    if (confirm(`Are you sure you want to delete the table ${tableName}?`)) {
        const result = await fetch(`${BASE_URL}/delete_table`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ table_name: tableName }),
        });
        alert(await result.json());
        fetchTables();
    }
}

async function editTable(tableName) {
    document.getElementById('edit-table-section').style.display = 'block';
    document.getElementById('table-list').style.display = 'none';
    document.getElementById('edit-table-name').textContent = tableName;

    const response = await fetch(`${BASE_URL}/get_table_data`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ table_name: tableName }),
    });

    const data = await response.json();

    const headers = document.getElementById('edit-table-headers');
    const rows = document.getElementById('edit-table-rows');

    headers.innerHTML = '';
    rows.innerHTML = '';

    if (data.length > 0) {
        // Populate headers
        const headerRow = document.createElement('tr');
        Object.keys(data[0]).forEach(key => {
            const th = document.createElement('th');
            th.textContent = key;
            headerRow.appendChild(th);
        });
        const actionTh = document.createElement('th');
        actionTh.textContent = 'Actions';
        headerRow.appendChild(actionTh);
        headers.appendChild(headerRow);

        // Populate rows
        data.forEach(row => {
            const tr = document.createElement('tr');
            Object.entries(row).forEach(([key, value]) => {
                const td = document.createElement('td');
                const input = document.createElement('input');
                input.type = 'text';
                input.value = value;
                input.dataset.column = key;
                td.appendChild(input);
                tr.appendChild(td);
            });

            // Add delete button
            const actionTd = document.createElement('td');
            const deleteButton = document.createElement('button');
            deleteButton.textContent = 'Delete';
            deleteButton.addEventListener('click', async () => {
                await deleteRow(tableName, row.id);
                editTable(tableName); // Refresh table after deletion
            });
            actionTd.appendChild(deleteButton);
            tr.appendChild(actionTd);

            rows.appendChild(tr);
        });
    } else {
        const noDataRow = document.createElement('tr');
        const noDataCell = document.createElement('td');
        noDataCell.colSpan = Object.keys(data[0] || {}).length + 1;
        noDataCell.textContent = 'No data available';
        noDataRow.appendChild(noDataCell);
        rows.appendChild(noDataRow);
    }
}

async function deleteRow(tableName, rowId) {
    const response = await fetch(`${BASE_URL}/delete`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ table_name: tableName, conditions: `id = ${rowId}` }),
    });
    const result = await response.json();
    alert(result.status || result.error);
}

document.getElementById('add-table-button').addEventListener('click', () => {
    document.getElementById('add-table').style.display = 'block';
});

document.getElementById('add-table-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const tableName = document.getElementById('table-name').value;
    const columns = document.getElementById('columns').value;
    const result = await fetch(`${BASE_URL}/add_table`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ table_name: tableName, columns }),
    });
    alert(await result.json());
    document.getElementById('add-table').style.display = 'none';
    fetchTables();
});

document.getElementById('save-table-changes').addEventListener('click', async () => {
    const tableName = document.getElementById('edit-table-name').textContent;
    const rows = document.querySelectorAll('#edit-table-rows tr');
    const updatedData = [];

    rows.forEach(row => {
        const rowData = {};
        row.querySelectorAll('input').forEach(input => {
            rowData[input.dataset.column] = input.value;
        });
        updatedData.push(rowData);
    });

    const response = await fetch(`${BASE_URL}/update_table_data`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ table_name: tableName, data: updatedData }),
    });

    const result = await response.json();
    alert(result.status || result.error);
});

document.getElementById('back-to-tables').addEventListener('click', () => {
    document.getElementById('edit-table-section').style.display = 'none';
    document.getElementById('table-list').style.display = 'block';
});

// Add event listener for Excel upload form
document.getElementById('excel-upload-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const fileInput = document.getElementById('excel-file');
    const file = fileInput.files[0];
    
    if (file) {
        document.getElementById('import-status').innerHTML = '<p>Uploading...</p>';
        await uploadExcel(file);
    }
});

// Fetch tables on page load
fetchTables();
