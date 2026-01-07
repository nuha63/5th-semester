import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import ttkbootstrap as tb
import numpy as np
import joblib
import pickle
import pandas as pd
import threading
import time
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
from fpdf import FPDF
import os
from datetime import datetime

# -------------------------
# CONFIG
# -------------------------
MODEL_FILENAME = "mental_health_model.pkl"   # change if needed
HISTORY_CSV = "history.csv"

# -------------------------
# Load model (joblib preferred)
# -------------------------
try:
    model = joblib.load(MODEL_FILENAME)
except Exception:
    try:
        with open(MODEL_FILENAME, "rb") as f:
            model = pickle.load(f)
    except Exception as e:
        model = None
        print("Could not load model:", e)

# -------------------------
# Question options & lists
# -------------------------
options = ["Not at all", "Several days", "More than half the days", "Nearly every day"]
opt_to_score = {"Not at all":0, "Several days":1, "More than half the days":2, "Nearly every day":3}

depression_questions = [
    "Feeling down, depressed or hopeless?",
    "Trouble falling/staying asleep or sleeping too much?",
    "Feeling tired or having little energy?",
    "Poor appetite or overeating?",
    "Feeling bad about yourself (failure/letting family down)?",
    "Trouble concentrating on studies or tasks?",
    "Moving/speaking slowly or being restless?",
    "Thoughts you'd be better off dead or self-harm?"
]

anxiety_questions = [
    "Feeling nervous, anxious or on edge?",
    "Not able to stop worrying?",
    "Worrying too much about different things?",
    "Trouble relaxing?",
    "Being restless?",
    "Becoming easily annoyed or irritated?",
    "Feeling afraid something awful might happen?"
]

stress_questions = [
    "Difficulty relaxing?",
    "Tended to over-react to situations?",
    "Using a lot of nervous energy?",
    "Found it hard to wind down?",
    "Excessive irritation?",
    "Agitated or upset easily?",
    "Difficulty managing pressure?",
    "Felt things were out of control?",
    "Felt stressed when workload increased?",
    "Trouble coping with semester pressure?"
]

# -------------------------
# Helper functions
# -------------------------
def safe_model_predict(X):
    """Call model.predict safely and return result or raise."""
    if model is None:
        raise RuntimeError("Model not loaded. Place '{}' in the same folder.".format(MODEL_FILENAME))
    return model.predict(X)

def save_history(row_dict):
    """Append a row to history CSV."""
    df = pd.DataFrame([row_dict])
    if not os.path.exists(HISTORY_CSV):
        df.to_csv(HISTORY_CSV, index=False)
    else:
        df.to_csv(HISTORY_CSV, mode='a', header=False, index=False)

def export_pdf(user_info, scores, prediction, out_path):
    """Create a simple PDF report with fpdf2."""
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=14, style="B")
    pdf.cell(0, 10, "Student Mental Health Report", ln=True, align="C")
    pdf.ln(6)
    pdf.set_font("Arial", size=11)
    pdf.cell(0, 7, f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", ln=True)
    pdf.ln(4)
    pdf.set_font("Arial", style="B", size=12)
    pdf.cell(0, 7, "Personal Information:", ln=True)
    pdf.set_font("Arial", size=11)
    for k,v in user_info.items():
        pdf.cell(0, 7, f"{k}: {v}", ln=True)
    pdf.ln(4)
    pdf.set_font("Arial", style="B", size=12)
    pdf.cell(0, 7, "Scores:", ln=True)
    pdf.set_font("Arial", size=11)
    pdf.cell(0,7, f"Depression Score: {scores['depression']}", ln=True)
    pdf.cell(0,7, f"Anxiety Score: {scores['anxiety']}", ln=True)
    pdf.cell(0,7, f"Stress Score: {scores['stress']}", ln=True)
    pdf.ln(4)
    pdf.set_font("Arial", style="B", size=12)
    pdf.cell(0,7, f"Predicted Mental Health Category: {prediction}", ln=True)
    pdf.output(out_path)
    return out_path

# -------------------------
# App UI
# -------------------------
app = tb.Window(themename="flatly")
app.title("Student Mental Health Assessment")
app.geometry("1000x800")

# Top headline
headline = ttk.Label(app, text="Student Mental Health Assessment System", font=("Helvetica", 20, "bold"))
headline.pack(pady=12)

# Notebook (tabs)
notebook = ttk.Notebook(app)
notebook.pack(fill="both", expand=True, padx=12, pady=8)

# Tab frames
tab_info = ttk.Frame(notebook)
tab_dep = ttk.Frame(notebook)
tab_anx = ttk.Frame(notebook)
tab_str = ttk.Frame(notebook)
tab_predict = ttk.Frame(notebook)

notebook.add(tab_info, text="Personal Info")
notebook.add(tab_dep, text="Depression")
notebook.add(tab_anx, text="Anxiety")
notebook.add(tab_str, text="Stress")
notebook.add(tab_predict, text="Predict")

# -------------------------
# Personal Info Tab
# -------------------------
info_frame = ttk.Frame(tab_info, padding=20)
info_frame.pack(expand=True)

lbl_age = ttk.Label(info_frame, text="Age:")
ent_age = ttk.Entry(info_frame, width=30)
lbl_gender = ttk.Label(info_frame, text="Gender:")
cb_gender = ttk.Combobox(info_frame, values=["Male","Female","Other"], width=28)
lbl_cgpa = ttk.Label(info_frame, text="Current CGPA:")
ent_cgpa = ttk.Entry(info_frame, width=30)
lbl_year = ttk.Label(info_frame, text="Academic Year:")
ent_year = ttk.Entry(info_frame, width=30)
lbl_dept = ttk.Label(info_frame, text="Department:")
ent_dept = ttk.Entry(info_frame, width=30)

# Center layout
lbl_age.grid(row=0,column=0, sticky="e", padx=6, pady=6)
ent_age.grid(row=0,column=1, sticky="w", padx=6, pady=6)
lbl_gender.grid(row=1,column=0, sticky="e", padx=6, pady=6)
cb_gender.grid(row=1,column=1, sticky="w", padx=6, pady=6)
lbl_cgpa.grid(row=2,column=0, sticky="e", padx=6, pady=6)
ent_cgpa.grid(row=2,column=1, sticky="w", padx=6, pady=6)
lbl_year.grid(row=3,column=0, sticky="e", padx=6, pady=6)
ent_year.grid(row=3,column=1, sticky="w", padx=6, pady=6)
lbl_dept.grid(row=4,column=0, sticky="e", padx=6, pady=6)
ent_dept.grid(row=4,column=1, sticky="w", padx=6, pady=6)

# -------------------------
# Depression tab (questions)
# -------------------------
dep_frame = ttk.Frame(tab_dep, padding=12)
dep_frame.pack(fill="both", expand=True)
dep_widgets = []
for i,q in enumerate(depression_questions):
    lbl = ttk.Label(dep_frame, text=q, wraplength=700)
    lbl.grid(row=i, column=0, sticky="w", pady=4, padx=6)
    cb = ttk.Combobox(dep_frame, values=options, width=35)
    cb.grid(row=i, column=1, pady=4)
    dep_widgets.append(cb)

# -------------------------
# Anxiety tab (questions)
# -------------------------
anx_frame = ttk.Frame(tab_anx, padding=12)
anx_frame.pack(fill="both", expand=True)
anx_widgets = []
for i,q in enumerate(anxiety_questions):
    lbl = ttk.Label(anx_frame, text=q, wraplength=700)
    lbl.grid(row=i, column=0, sticky="w", pady=4, padx=6)
    cb = ttk.Combobox(anx_frame, values=options, width=35)
    cb.grid(row=i, column=1, pady=4)
    anx_widgets.append(cb)

# -------------------------
# Stress tab (questions)
# -------------------------
str_frame = ttk.Frame(tab_str, padding=12)
str_frame.pack(fill="both", expand=True)
str_widgets = []
for i,q in enumerate(stress_questions):
    lbl = ttk.Label(str_frame, text=q, wraplength=700)
    lbl.grid(row=i, column=0, sticky="w", pady=4, padx=6)
    cb = ttk.Combobox(str_frame, values=options, width=35)
    cb.grid(row=i, column=1, pady=4)
    str_widgets.append(cb)

# -------------------------
# Predict tab: progress bar, result, pie chart and PDF export
# -------------------------
pred_frame = ttk.Frame(tab_predict, padding=12)
pred_frame.pack(fill="both", expand=True)

# Progress bar
progress = ttk.Progressbar(pred_frame, orient="horizontal", mode="indeterminate", length=400)
progress.pack(pady=10)

# Result label
result_var = tk.StringVar(value="No prediction yet.")
result_label = ttk.Label(pred_frame, textvariable=result_var, font=("Arial", 14, "bold"))
result_label.pack(pady=10)

# Details label to show per-scale levels under the result
details_var = tk.StringVar(value="")
details_label = ttk.Label(pred_frame, textvariable=details_var, font=("Arial", 11))
details_label.pack(pady=4)

# Pie chart area
fig, ax = plt.subplots(figsize=(4,4))
canvas = FigureCanvasTkAgg(fig, master=pred_frame)
canvas_widget = canvas.get_tk_widget()
canvas_widget.pack(pady=8)

# Buttons row
btn_frame = ttk.Frame(pred_frame)
btn_frame.pack(pady=6)

btn_predict = ttk.Button(btn_frame, text="Predict", bootstyle="success")
btn_pdf = ttk.Button(btn_frame, text="Export PDF Report")
btn_save = ttk.Button(btn_frame, text="Save to History")
btn_clear = ttk.Button(btn_frame, text="Clear Form")

btn_predict.grid(row=0, column=0, padx=6)
btn_pdf.grid(row=0, column=1, padx=6)
btn_save.grid(row=0, column=2, padx=6)
btn_clear.grid(row=0, column=3, padx=6)

# -------------------------
# Core logic: collect inputs, validate, create feature vector
# -------------------------
def collect_inputs():
    # Personal info
    try:
        age = int(ent_age.get())
    except:
        raise ValueError("Age must be an integer.")
    gender = cb_gender.get()
    if gender not in ["Male","Female","Other"]:
        raise ValueError("Select Gender.")
    gender_num = 1 if gender=="Female" else 0
    try:
        cgpa = float(ent_cgpa.get())
    except:
        raise ValueError("CGPA must be numeric.")
    year = ent_year.get()
    dept = ent_dept.get()

    # Questions
    def get_scores(wlist, label):
        scores = []
        for cb in wlist:
            v = cb.get()
            if v not in opt_to_score:
                raise ValueError(f"Answer all {label} questions.")
            scores.append(opt_to_score[v])
        return scores

    d_scores = get_scores(dep_widgets, "depression")
    a_scores = get_scores(anx_widgets, "anxiety")
    s_scores = get_scores(str_widgets, "stress")

    # Totals
    depression_sum = sum(d_scores)
    anxiety_sum = sum(a_scores)
    stress_sum = sum(s_scores)

    # Feature vector assumed: [age, gender_num, cgpa] + depression Qs + anxiety Qs + stress Qs
    feat = [age, gender_num, cgpa] + d_scores + a_scores + s_scores
    return {
        "age": age, "gender": gender, "gender_num": gender_num, "cgpa": cgpa, "year": year, "dept": dept,
        "depression_scores": d_scores, "anxiety_scores": a_scores, "stress_scores": s_scores,
        "depression_sum": depression_sum, "anxiety_sum": anxiety_sum, "stress_sum": stress_sum,
        "feature_vector": np.array(feat).reshape(1,-1)
    }

# -------------------------
# Prediction worker (runs in thread to animate progress bar)
# -------------------------
def prediction_worker():
    try:
        inputs = collect_inputs()
    except Exception as e:
        progress.stop()
        btn_predict.config(state="normal")
        messagebox.showerror("Input Error", str(e))
        return

    # animate progress bar
    progress.start(10)
    btn_predict.config(state="disabled")

    # simulate small delay and run the model
    # Note: replace time.sleep with actual heavy work if needed
    time.sleep(0.5)
    try:
        # The trained pipeline expects a DataFrame with specific columns
        # (e.g. 37 columns). Build a single-row DataFrame using the
        # pipeline's expected column names and map GUI inputs to them.
        try:
            expected_cols = list(model.named_steps['preprocess'].feature_names_in_)
        except Exception:
            # If model metadata not available, fall back to the raw vector
            X = inputs["feature_vector"]
            y_pred = safe_model_predict(X)
            pred_text = str(y_pred[0])
        else:
            # prepare mapping of question texts to scores
            q_map = {}
            for i, q in enumerate(depression_questions, 1):
                q_map[q.lower()] = inputs['depression_scores'][i-1]
            for i, q in enumerate(anxiety_questions, 1):
                q_map[q.lower()] = inputs['anxiety_scores'][i-1]
            for i, q in enumerate(stress_questions, 1):
                q_map[q.lower()] = inputs['stress_scores'][i-1]

            # helper: simple token-overlap score
            def score_match(colname, qtext):
                s1 = set([w for w in colname.lower().split() if len(w) > 3])
                s2 = set([w for w in qtext.lower().split() if len(w) > 3])
                return len(s1 & s2)

            # compute aggregated values the pipeline may expect
            anxiety_sum = inputs['anxiety_sum']
            stress_sum = inputs['stress_sum']
            depression_sum = inputs['depression_sum']

            # age bucket
            def age_bucket(a):
                try:
                    a = int(a)
                except Exception:
                    return 'Unknown'
                if a < 18:
                    return 'Below 18'
                if 18 <= a <= 22:
                    return '18-22'
                if 23 <= a <= 26:
                    return '23-26'
                if 27 <= a <= 30:
                    return '27-30'
                return 'Above 30'

            row = {}
            for c in expected_cols:
                cl = c.lower()
                # known personal fields (categorical)
                if '1. age' in cl or cl.strip() == '1. age':
                    row[c] = age_bucket(inputs['age'])
                    continue
                if '2. gender' in cl or cl.strip() == '2. gender' or cl == 'gender':
                    row[c] = inputs['gender']
                    continue
                if '6. current cgpa' in cl or 'cgpa' in cl:
                    row[c] = str(inputs['cgpa'])
                    continue
                if 'university' in cl:
                    row[c] = ''
                    continue
                if 'waiver' in cl or 'scholarship' in cl:
                    row[c] = 'No'
                    continue
                # aggregated numeric fields
                if 'anxiety value' in cl:
                    row[c] = anxiety_sum
                    continue
                if 'stress value' in cl:
                    row[c] = stress_sum
                    continue
                if 'anxiety label' in cl or 'stress label' in cl:
                    row[c] = ''
                    continue

                # try fuzzy match to questions
                best_score = 0
                best_val = None
                for qtext, val in q_map.items():
                    sc = score_match(c, qtext)
                    if sc > best_score:
                        best_score = sc
                        best_val = val
                if best_score > 0:
                    row[c] = best_val
                else:
                    # default numeric fallback
                    row[c] = 0

            X = pd.DataFrame([row], columns=expected_cols)

            # Ensure numeric columns are numeric before transformers run
            try:
                num_cols = list(model.named_steps['preprocess'].transformers[0][2])
            except Exception:
                num_cols = []
            for col in num_cols:
                if col in X.columns:
                    X[col] = pd.to_numeric(X[col], errors='coerce').fillna(0)

            y_pred = safe_model_predict(X)
            pred_text = str(y_pred[0])
    except Exception as e:
        progress.stop()
        btn_predict.config(state="normal")
        messagebox.showerror("Prediction Error", str(e))
        return

    # stop animation
    progress.stop()
    btn_predict.config(state="normal")

    # update result label
    result_var.set(f"Predicted Mental Health Category: {pred_text}")

    # draw pie chart: show three scores proportionally and also compute levels
    ax.clear()
    labels = ["Depression", "Anxiety", "Stress"]
    values = [inputs["depression_sum"], inputs["anxiety_sum"], inputs["stress_sum"]]

    # compute max possible for each scale (3 points per question)
    max_depr = len(depression_questions) * 3
    max_anx = len(anxiety_questions) * 3
    max_str = len(stress_questions) * 3
    maxes = [max_depr, max_anx, max_str]

    # level mapping (proportional). Adjust thresholds if you prefer clinical cutoffs.
    def map_level(score, max_score):
        if max_score <= 0:
            return 'Unknown'
        p = score / float(max_score)
        if p < 0.2:
            return 'Normal'
        if p < 0.4:
            return 'Mild'
        if p < 0.6:
            return 'Moderate'
        if p < 0.8:
            return 'Severe'
        return 'Very Severe'

    levels = [map_level(values[0], maxes[0]), map_level(values[1], maxes[1]), map_level(values[2], maxes[2])]

    # avoid all zeros (so pie draws sensibly)
    if sum(values) == 0:
        values = [1, 1, 1]

    colors = ["#ff9999","#66b3ff","#99ff99"]
    wedges, texts, autotexts = ax.pie(values, labels=labels, autopct="%1.1f%%", colors=colors, startangle=90)
    ax.axis("equal")
    ax.set_title("Score distribution")

    # show per-scale levels in the details label below the result
    details_lines = [
        f"Depression: {levels[0]} ({inputs['depression_sum']}/{maxes[0]})",
        f"Anxiety: {levels[1]} ({inputs['anxiety_sum']}/{maxes[1]})",
        f"Stress: {levels[2]} ({inputs['stress_sum']}/{maxes[2]})",
    ]
    details_var.set('\n'.join(details_lines))

    canvas.draw()

    # store last prediction/result for PDF/save
    pred_frame.last_result = {
        "user_info": {"Age": inputs["age"], "Gender": inputs["gender"], "CGPA": inputs["cgpa"], "Year": inputs["year"], "Department": inputs["dept"]},
        "scores": {"depression": inputs["depression_sum"], "anxiety": inputs["anxiety_sum"], "stress": inputs["stress_sum"]},
        "levels": {"depression_level": levels[0], "anxiety_level": levels[1], "stress_level": levels[2]},
        "prediction": pred_text
    }

# -------------------------
# Button callbacks
# -------------------------
def on_predict():
    # run worker thread so UI remains responsive and progress animates
    t = threading.Thread(target=prediction_worker, daemon=True)
    t.start()

def on_export_pdf():
    if not hasattr(pred_frame, "last_result"):
        messagebox.showwarning("No result", "Please run a prediction first.")
        return
    out = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files","*.pdf")])
    if not out:
        return
    info = pred_frame.last_result["user_info"]
    scores = pred_frame.last_result["scores"]
    pred = pred_frame.last_result["prediction"]
    try:
        export_pdf(info, scores, pred, out)
        messagebox.showinfo("Saved", f"PDF report saved to:\n{out}")
    except Exception as e:
        messagebox.showerror("Error", f"Could not create PDF:\n{e}")

def on_save_history():
    if not hasattr(pred_frame, "last_result"):
        messagebox.showwarning("No result", "Please run a prediction first.")
        return
    rec = pred_frame.last_result
    row = {
        "timestamp": datetime.now().isoformat(),
        "age": rec["user_info"]["Age"],
        "gender": rec["user_info"]["Gender"],
        "cgpa": rec["user_info"]["CGPA"],
        "year": rec["user_info"]["Year"],
        "department": rec["user_info"]["Department"],
        "depression_score": rec["scores"]["depression"],
        "anxiety_score": rec["scores"]["anxiety"],
        "stress_score": rec["scores"]["stress"],
        "prediction": rec["prediction"]
    }
    save_history(row)
    messagebox.showinfo("Saved", f"Record saved to {HISTORY_CSV}")

def on_clear():
    # clear personal info
    ent_age.delete(0, tk.END)
    ent_cgpa.delete(0, tk.END)
    ent_year.delete(0, tk.END)
    ent_dept.delete(0, tk.END)
    cb_gender.set("")
    # clear all comboboxes
    for w in dep_widgets + anx_widgets + str_widgets:
        w.set("")
    result_var.set("No prediction yet.")
    ax.clear()
    canvas.draw()
    if hasattr(pred_frame, "last_result"):
        del pred_frame.last_result

# attach callbacks
btn_predict.config(command=on_predict)
btn_pdf.config(command=on_export_pdf)
btn_save.config(command=on_save_history)
btn_clear.config(command=on_clear)

# Start UI
app.mainloop()
