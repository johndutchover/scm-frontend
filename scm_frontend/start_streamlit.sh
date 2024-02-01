#!/bin/sh
# streamlit run pages/page_1.py --server.port=8501 --server.address=$MY_IP_ADDRESS
# .venv/bin/streamlit run main.py --server.port=8501 --server.address=$MY_IP_ADDRESS
# streamlit run main.py --server.port=8501 --server.address=$MY_IP_ADDRESS
streamlit run main.py --server.port=8501 --server.address=0.0.0.0
